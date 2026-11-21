#!/usr/bin/env node
// Assembles a video from an edit list with ffmpeg: a low quality review render or a high quality final render.
// Usage: node build-render.mjs <edl.json> <review|final> <out-dir> [options]
//   --version N        review version number (default 1)
//   --captions MODE    burn | srt | none (default: edl.captions_mode or "none")
//   --no-labels        review only: do not burn scene labels and time
//   --plan             check the edit list and print the plan, do not render
// Needs: Node 18+, ffmpeg and ffprobe on PATH (ffmpeg with libx264 and libass). No other packages.
//
// edl.json: see references/edl-format.md in the skill folder.

import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdirSync, existsSync, statSync, rmSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { join, resolve, basename } from 'node:path';

const argv = process.argv.slice(2);
const flag = (name) => argv.includes(name);
const opt = (name, dflt) => { const i = argv.indexOf(name); return i >= 0 ? argv[i + 1] : dflt; };
const pos = [];
for (let i = 0; i < argv.length; i++) {
  if (argv[i].startsWith('--')) { if (['--version', '--captions'].includes(argv[i])) i++; continue; }
  pos.push(argv[i]);
}
const [edlPath, mode, outDirArg] = pos;
if (!edlPath || !['review', 'final'].includes(mode) || !outDirArg) {
  console.error('usage: node build-render.mjs <edl.json> <review|final> <out-dir> [--version N] [--captions burn|srt|none] [--no-labels] [--plan]');
  process.exit(2);
}

const edl = JSON.parse(readFileSync(edlPath, 'utf8'));
const planOnly = flag('--plan');
const version = Number(opt('--version', 1));
const captionsMode = opt('--captions', edl.captions_mode || 'none');
const labels = mode === 'review' && !flag('--no-labels');
const slug = edl.slug || 'video';
const fps = Number(edl.fps || 24);
const finalW = Number(edl.width || 1920);
const finalH = Number(edl.height || 1080);
const even = (n) => Math.max(2, Math.round(n / 2) * 2);
const rv = edl.review || {};
const H = mode === 'review' ? even(Number(rv.height || 360)) : finalH;
const W = mode === 'review' ? even(H * finalW / finalH) : finalW;
const crf = mode === 'review' ? Number(rv.crf ?? 32) : Number(edl.final?.crf ?? 18);
const segCrf = mode === 'review' ? crf : Number(edl.final?.segment_crf ?? 14);
const preset = mode === 'review' ? (rv.preset || 'veryfast') : (edl.final?.preset || 'slow');
const audioBitrate = mode === 'review' ? (rv.audio_bitrate || '96k') : (edl.final?.audio_bitrate || '192k');
const target = edl.loudness || { i: -14, tp: -1.5, lra: 11 };

function fail(msg) { console.error(msg); process.exit(1); }
function run(cmd, args, opts = {}) {
  const r = spawnSync(cmd, args, { encoding: 'utf8', maxBuffer: 1 << 28, ...opts });
  if (r.error) fail(`${cmd} failed to start: ${r.error.message}`);
  if (r.status !== 0 && !opts.allowFail) fail(`${cmd} exited ${r.status}\n${(r.stderr || '').split('\n').slice(-14).join('\n')}`);
  return r;
}
// ffmpeg 7+ reads a filter graph file with -/filter_complex; older versions use -filter_complex_script.
function runGraph(inArgs, graphFile, rest, opts = {}) {
  const tryNew = run('ffmpeg', ['-y', '-v', 'error', ...inArgs, '-/filter_complex', graphFile, ...rest], { ...opts, allowFail: true });
  if (tryNew.status === 0) return tryNew;
  if (/Unrecognized option|Option not found/i.test(tryNew.stderr || '')) return run('ffmpeg', ['-y', '-v', 'error', ...inArgs, '-filter_complex_script', graphFile, ...rest], opts);
  fail(`ffmpeg exited ${tryNew.status}\n${(tryNew.stderr || '').split('\n').slice(-14).join('\n')}`);
}
const probeDur = (f) => Number(run('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'default=nw=1:nk=1', f]).stdout.trim());
const fwd = (p) => resolve(p).replace(/\\/g, '/');

// ---------- check the edit list ----------
const scenes = edl.scenes || [];
const problems = [];
const warnings = [];
let cursor = 0;
for (const s of scenes) {
  if (!(Number(s.duration) > 0)) problems.push(`scene ${s.n}: duration must be > 0`);
  if (s.start == null) s.start = cursor;
  if (Math.abs(Number(s.start) - cursor) > 0.01) warnings.push(`scene ${s.n}: start ${s.start} differs from the sum of earlier scenes (${cursor.toFixed(3)}); using the sum`);
  s.start = cursor;
  cursor += Number(s.duration);
  const v = s.visual || {};
  const f = v.type === 'clip' ? v.file : v.image;
  if (!f || !existsSync(f)) problems.push(`scene ${s.n}: visual file not found: ${f}`);
}
const total = cursor;
for (const v of edl.voice || []) if (!existsSync(v.file)) problems.push(`voice file not found: ${v.file}`);
for (const st of edl.stems || []) if (!existsSync(st.file)) problems.push(`stem file not found: ${st.file}`);
if (problems.length) fail('Problems:\n- ' + problems.join('\n- '));
if (!scenes.length) fail('The edit list has no scenes.');

// voice lines that run over their scene or past the end
const sceneAt = (t) => scenes.find((s) => t >= s.start - 1e-6 && t < s.start + s.duration - 1e-6);
if (!planOnly || true) {
  for (const v of edl.voice || []) {
    const d = probeDur(v.file);
    const s = sceneAt(Number(v.t));
    if (s && Number(v.t) + d > s.start + s.duration + 0.05) warnings.push(`voice ${basename(v.file)} ends ${(Number(v.t) + d - s.start - s.duration).toFixed(2)} s after scene ${s.n} ends`);
    if (Number(v.t) + d > total + 0.05) warnings.push(`voice ${basename(v.file)} runs past the end of the video`);
  }
}

console.log(`${mode} render: ${W}x${H} @ ${fps} fps, ${scenes.length} scenes, ${total.toFixed(2)} s`);
for (const w of warnings) console.warn('warning: ' + w);
if (planOnly) process.exit(0);

// ---------- folders ----------
const outDir = resolve(outDirArg);
const work = join(outDir, `work_${mode}`);
const segDir = join(work, 'segments');
mkdirSync(segDir, { recursive: true });

// ---------- visual segments (cached) ----------
const moveExpr = (move, N) => {
  switch (move) {
    case 'push-in': return { z: `1+0.12*on/${N}`, x: 'iw/2-(iw/zoom/2)', y: 'ih/2-(ih/zoom/2)' };
    case 'pull-out': return { z: `1.12-0.12*on/${N}`, x: 'iw/2-(iw/zoom/2)', y: 'ih/2-(ih/zoom/2)' };
    case 'pan-left': return { z: '1.12', x: `(iw-iw/zoom)*(1-on/${N})`, y: '(ih-ih/zoom)/2' };
    case 'pan-right': return { z: '1.12', x: `(iw-iw/zoom)*(on/${N})`, y: '(ih-ih/zoom)/2' };
    default: return { z: '1', x: '0', y: '0' };
  }
};
const fadeLen = 0.4;
const stamp = (f) => { const s = statSync(f); return `${s.size}:${Math.round(s.mtimeMs)}`; };

let rendered = 0, reused = 0;
const segFiles = [];
scenes.forEach((s, idx) => {
  const v = s.visual;
  const N = Math.max(1, Math.round(s.duration * fps));
  const fadeOut = s.transition_out === 'fade';
  const prev = scenes[idx - 1];
  const fadeIn = prev && prev.transition_out === 'fade';
  const src = v.type === 'clip' ? v.file : v.image;
  const spec = { v, N, fadeOut, fadeIn, W, H, fps, segCrf, preset, src: stamp(src) };
  const hash = createHash('sha1').update(JSON.stringify(spec)).digest('hex');
  const name = `scene-${String(s.n).padStart(3, '0')}.mp4`;
  const file = join(segDir, name);
  const meta = file + '.hash';
  segFiles.push(file);
  if (existsSync(file) && existsSync(meta) && readFileSync(meta, 'utf8') === hash) { reused++; return; }

  const fade = [];
  if (fadeIn) fade.push(`fade=t=in:st=0:d=${fadeLen}`);
  if (fadeOut) fade.push(`fade=t=out:st=${Math.max(0, s.duration - fadeLen).toFixed(3)}:d=${fadeLen}`);
  let vf, input;
  if (v.type === 'clip') {
    input = ['-ss', String(v.trim_start || 0), '-i', v.file];
    vf = [`scale=${W}:${H}:force_original_aspect_ratio=increase`, `crop=${W}:${H}`, `fps=${fps}`, 'setsar=1',
      `tpad=stop_mode=clone:stop_duration=${s.duration.toFixed ? s.duration.toFixed(3) : s.duration}`, `trim=duration=${Number(s.duration).toFixed(3)}`, 'setpts=PTS-STARTPTS', ...fade];
  } else {
    const m = moveExpr(v.move, N);
    input = ['-i', v.image];
    vf = [`scale=${W * 2}:${H * 2}:force_original_aspect_ratio=increase`, `crop=${W * 2}:${H * 2}`,
      `zoompan=z='${m.z}':x='${m.x}':y='${m.y}':d=${N}:s=${W}x${H}:fps=${fps}`, 'setsar=1', ...fade];
  }
  run('ffmpeg', ['-y', '-v', 'error', ...input, '-vf', vf.join(','), '-frames:v', String(N), '-an',
    '-c:v', 'libx264', '-preset', preset, '-crf', String(segCrf), '-pix_fmt', 'yuv420p', '-r', String(fps), file]);
  writeFileSync(meta, hash);
  rendered++;
});
console.log(`segments: ${rendered} rendered, ${reused} reused`);

// concat (all segments share codec settings)
const listFile = join(work, 'concat.txt');
writeFileSync(listFile, segFiles.map((f) => `file '${fwd(f)}'`).join('\n') + '\n');
const videoOnly = join(work, 'video_only.mp4');
run('ffmpeg', ['-y', '-v', 'error', '-f', 'concat', '-safe', '0', '-i', listFile, '-c', 'copy', videoOnly]);

// ---------- audio ----------
const sr = 48000;
const voice = edl.voice || [];
let voiceTrack = null;
if (voice.length) {
  const chunks = [];
  for (let i = 0; i < voice.length; i += 40) {
    const part = voice.slice(i, i + 40);
    const inArgs = part.flatMap((v) => ['-i', v.file]);
    const chain = part.map((v, k) => `[${k}:a]aresample=${sr},aformat=channel_layouts=stereo,volume=${Number(v.gain_db || 0)}dB,adelay=${Math.round(v.t * 1000)}|${Math.round(v.t * 1000)}[v${k}]`);
    const graph = chain.join(';') + ';' + part.map((_, k) => `[v${k}]`).join('') + `amix=inputs=${part.length}:normalize=0:duration=longest,apad=whole_dur=${total}[o]`;
    const gfile = join(work, `voice_graph_${i}.txt`);
    writeFileSync(gfile, graph);
    const out = join(work, `voice_chunk_${i}.wav`);
    runGraph(inArgs, gfile, ['-map', '[o]', '-t', String(total), '-ar', String(sr), '-c:a', 'pcm_s24le', out]);
    chunks.push(out);
  }
  if (chunks.length === 1) voiceTrack = chunks[0];
  else {
    voiceTrack = join(work, 'voice_track.wav');
    run('ffmpeg', ['-y', '-v', 'error', ...chunks.flatMap((c) => ['-i', c]), '-filter_complex', `amix=inputs=${chunks.length}:normalize=0`, '-t', String(total), '-c:a', 'pcm_s24le', voiceTrack]);
  }
}
const mixInputs = [];
if (voiceTrack) mixInputs.push({ file: voiceTrack, gain: Number(edl.voice_gain_db || 0) });
for (const st of edl.stems || []) mixInputs.push({ file: st.file, gain: Number(st.gain_db || 0) });
const mixFile = join(work, 'mix.wav');
if (mixInputs.length) {
  const inArgs = mixInputs.flatMap((m) => ['-i', m.file]);
  const chain = mixInputs.map((m, k) => `[${k}:a]aresample=${sr},aformat=channel_layouts=stereo,volume=${m.gain}dB[m${k}]`).join(';');
  const base = chain + ';' + mixInputs.map((_, k) => `[m${k}]`).join('') + `amix=inputs=${mixInputs.length}:normalize=0:duration=longest,apad=whole_dur=${total},atrim=duration=${total}`;
  const ln = `I=${target.i}:TP=${target.tp}:LRA=${target.lra ?? 11}`;
  let normFilter = `loudnorm=${ln}`;
  if (mode === 'final') {
    const pass1 = run('ffmpeg', ['-y', '-hide_banner', ...inArgs, '-filter_complex', `${base},loudnorm=${ln}:print_format=json[o]`, '-map', '[o]', '-f', 'null', '-'], { allowFail: true });
    const m = /\{[^{}]*"input_i"[^{}]*\}/s.exec(pass1.stderr || '');
    if (m) {
      const j = JSON.parse(m[0]);
      normFilter = `loudnorm=${ln}:measured_I=${j.input_i}:measured_TP=${j.input_tp}:measured_LRA=${j.input_lra}:measured_thresh=${j.input_thresh}:offset=${j.target_offset}:linear=true`;
    } else warnings.push('loudness measuring pass gave no result; used one-pass normalization');
  }
  const gfile = join(work, 'mix_graph.txt');
  writeFileSync(gfile, `${base},${normFilter}[o]`);
  runGraph(inArgs, gfile, ['-map', '[o]', '-ar', String(sr), '-c:a', 'pcm_s24le', mixFile]);
} else warnings.push('no voice and no stems: the video will be silent');

// ---------- captions and review labels (one ASS file) ----------
const ts = (t) => { const c = Math.round(t * 100); const h = Math.floor(c / 360000), m = Math.floor((c % 360000) / 6000), s = Math.floor((c % 6000) / 100), cs = c % 100; return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}.${String(cs).padStart(2, '0')}`; };
const srtTs = (t) => { const ms = Math.round(t * 1000); const h = Math.floor(ms / 3600000), m = Math.floor((ms % 3600000) / 60000), s = Math.floor((ms % 60000) / 1000), x = ms % 1000; return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')},${String(x).padStart(3, '0')}`; };
const clean = (t) => String(t).replace(/[{}]/g, '').replace(/\r?\n/g, ' ');
const caps = edl.captions || [];
const events = [];
if (captionsMode === 'burn') for (const c of caps) events.push(`Dialogue: 0,${ts(c.start)},${ts(c.end)},Caption,,0,0,0,,${clean(c.text)}`);
if (labels) for (const s of scenes) {
  const mm = Math.floor(s.start / 60), ss = Math.floor(s.start % 60);
  events.push(`Dialogue: 1,${ts(s.start)},${ts(s.start + s.duration)},Label,,0,0,0,,scene ${String(s.n).padStart(3, '0')}  ${String(mm).padStart(2, '0')}:${String(ss).padStart(2, '0')}  REVIEW v${version}`);
}
let assName = null;
if (events.length) {
  const capSize = Math.round(H / 22), labSize = Math.round(H / 34);
  const ass = `[Script Info]\nScriptType: v4.00+\nPlayResX: ${W}\nPlayResY: ${H}\nWrapStyle: 0\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\nStyle: Caption,Arial,${capSize},&H00FFFFFF,&H000000FF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,1,2,1,2,${Math.round(W * 0.08)},${Math.round(W * 0.08)},${Math.round(H * 0.06)},1\nStyle: Label,Arial,${labSize},&H0000FFFF,&H000000FF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,3,2,0,7,${Math.round(W * 0.02)},10,${Math.round(H * 0.02)},1\n\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\n${events.join('\n')}\n`;
  assName = 'overlay.ass';
  writeFileSync(join(work, assName), ass);
}

// ---------- mux ----------
const base = mode === 'review' ? `${slug}_review_v${version}.mp4` : `${slug}_final.mp4`;
const outFile = join(outDir, base);
const needsReencode = Boolean(assName);
const args = ['-y', '-v', 'error', '-i', 'video_only.mp4'];
if (mixInputs.length) args.push('-i', 'mix.wav');
if (needsReencode) args.push('-vf', `subtitles=${assName}`, '-c:v', 'libx264', '-preset', preset, '-crf', String(crf), '-pix_fmt', 'yuv420p');
else if (mode === 'final') args.push('-c:v', 'copy');
else args.push('-c:v', 'libx264', '-preset', preset, '-crf', String(crf), '-pix_fmt', 'yuv420p');
if (mixInputs.length) args.push('-c:a', 'aac', '-b:a', audioBitrate, '-ar', '48000', '-t', String(total));
else args.push('-an', '-t', String(total));
args.push('-movflags', '+faststart', resolve(outFile));
run('ffmpeg', args, { cwd: work });
if (mode === 'final' && !needsReencode) warnings.push('final video stream copied from segments encoded at the segment quality setting');

if (captionsMode === 'srt' && caps.length) {
  const srt = caps.map((c, i) => `${i + 1}\n${srtTs(c.start)} --> ${srtTs(c.end)}\n${clean(c.text)}\n`).join('\n');
  writeFileSync(join(outDir, `${slug}${mode === 'review' ? `_review_v${version}` : '_final'}.srt`), srt);
}

// ---------- report ----------
const probe = JSON.parse(run('ffprobe', ['-v', 'error', '-show_entries', 'format=duration,size:stream=codec_type,codec_name,width,height,r_frame_rate', '-of', 'json', outFile]).stdout);
let loud = null;
const ebu = run('ffmpeg', ['-hide_banner', '-nostats', '-i', outFile, '-af', 'ebur128=peak=true', '-f', 'null', '-'], { allowFail: true }).stderr || '';
const li = /I:\s+(-?[\d.]+) LUFS/.exec(ebu.split('Summary:')[1] || ''), lp = /Peak:\s+(-?[\d.]+) dBFS/.exec(ebu.split('Summary:')[1] || '');
if (li) loud = { integrated_lufs: Number(li[1]), true_peak_dbfs: lp ? Number(lp[1]) : null };
const report = {
  mode, version: mode === 'review' ? version : null, file: resolve(outFile),
  planned_seconds: total, actual_seconds: Number(probe.format.duration), size_mb: Number((probe.format.size / 1048576).toFixed(1)),
  streams: probe.streams, loudness: loud, warnings,
};
writeFileSync(join(outDir, `${base}.report.json`), JSON.stringify(report, null, 2));
console.log(`wrote ${resolve(outFile)}`);
console.log(`duration ${report.actual_seconds.toFixed(2)} s (planned ${total.toFixed(2)} s), ${report.size_mb} MB` + (loud ? `, ${loud.integrated_lufs} LUFS, peak ${loud.true_peak_dbfs} dBFS` : ''));
for (const w of warnings) console.warn('warning: ' + w);

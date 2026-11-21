#!/usr/bin/env node
// Places sound files on a timeline from a cue sheet and writes stems with ffmpeg.
// Usage: node mix-cues.mjs <cues.json> <out-dir> [--plan]
// Needs: Node 18+, ffmpeg and ffprobe on PATH. No other packages.
//
// cues.json:
// {
//   "total_seconds": 612.5,
//   "sample_rate": 48000,
//   "duck": { "db": 10, "ramp": 0.35, "regions": [[2.0, 8.1], [9.0, 14.2]] },
//   "cues": [
//     { "id": "c1", "stem": "sfx", "file": "sound/cut/scene-007_sfx_01_door.wav", "t": 41.2,
//       "gain_db": -6, "trim_start": 0, "trim_end": null, "fade_in": 0.01, "fade_out": 0.1 },
//     { "id": "m1", "stem": "music", "file": "sound/cut/music_01_theme.mp3", "t": 0, "end": 612.5,
//       "gain_db": -20, "fade_in": 3, "fade_out": 6, "loop": true, "duck": true },
//     { "id": "a1", "stem": "amb", "file": "sound/cut/scene-001_amb_01_sea.wav", "t": 0, "end": 60,
//       "gain_db": -26, "fade_in": 2, "fade_out": 2, "loop": true, "duck": false }
//   ]
// }
// stem: "sfx" | "amb" | "music". "duck": true lowers that cue while a duck region is active.
// File paths are relative to the current directory or absolute.

import { spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { join, resolve } from 'node:path';

const args = process.argv.slice(2);
const planOnly = args.includes('--plan');
const [cuePath, outDir] = args.filter((a) => !a.startsWith('--'));
if (!cuePath || !outDir) {
  console.error('usage: node mix-cues.mjs <cues.json> <out-dir> [--plan]');
  process.exit(2);
}

const sheet = JSON.parse(readFileSync(cuePath, 'utf8'));
const total = Number(sheet.total_seconds);
const sr = Number(sheet.sample_rate || 48000);
if (!(total > 0)) fail('total_seconds must be a positive number');
const cues = sheet.cues || [];
const problems = [];

for (const c of cues) {
  if (!['sfx', 'amb', 'music'].includes(c.stem)) problems.push(`${c.id}: stem must be sfx, amb or music`);
  if (!(Number(c.t) >= 0)) problems.push(`${c.id}: t must be >= 0`);
  if (Number(c.t) >= total) problems.push(`${c.id}: t ${c.t} is after the end of the video (${total})`);
  if (!existsSync(c.file)) problems.push(`${c.id}: file not found: ${c.file}`);
}
if (problems.length) {
  console.error('Problems:\n- ' + problems.join('\n- '));
  process.exit(1);
}

function fail(msg) {
  console.error(msg);
  process.exit(1);
}

function run(cmd, cmdArgs) {
  const r = spawnSync(cmd, cmdArgs, { encoding: 'utf8' });
  if (r.error) fail(`${cmd} failed to start: ${r.error.message}`);
  if (r.status !== 0) fail(`${cmd} exited ${r.status}\n${(r.stderr || '').split('\n').slice(-12).join('\n')}`);
  return r.stdout;
}

function duration(file) {
  const out = run('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'default=nw=1:nk=1', file]);
  return Number(out.trim());
}

// Writes a mono 32-bit float WAV holding the ducking gain (0..1) at 200 Hz.
function writeDuckEnvelope(path) {
  const rate = 200;
  const n = Math.ceil(total * rate) + 1;
  const duck = sheet.duck || {};
  const depth = Number(duck.db ?? 10);
  const ramp = Math.max(0.02, Number(duck.ramp ?? 0.35));
  const regions = duck.regions || [];
  const buf = Buffer.alloc(44 + n * 4);
  buf.write('RIFF', 0); buf.writeUInt32LE(36 + n * 4, 4); buf.write('WAVE', 8);
  buf.write('fmt ', 12); buf.writeUInt32LE(16, 16); buf.writeUInt16LE(3, 20); buf.writeUInt16LE(1, 22);
  buf.writeUInt32LE(rate, 24); buf.writeUInt32LE(rate * 4, 28); buf.writeUInt16LE(4, 32); buf.writeUInt16LE(32, 34);
  buf.write('data', 36); buf.writeUInt32LE(n * 4, 40);
  const floor = Math.pow(10, -depth / 20);
  for (let i = 0; i < n; i++) {
    const t = i / rate;
    let amount = 0; // 0 = no ducking, 1 = full ducking
    for (const [a, b] of regions) {
      const up = (t - (a - ramp)) / ramp;
      const down = ((b + ramp) - t) / ramp;
      amount = Math.max(amount, Math.min(1, Math.max(0, Math.min(up, down))));
    }
    const gain = 1 - amount * (1 - floor);
    buf.writeFloatLE(gain, 44 + i * 4);
  }
  writeFileSync(path, buf);
}

mkdirSync(outDir, { recursive: true });
const duckPath = resolve(outDir, '_duck_envelope.wav');
const needsDuck = cues.some((c) => c.duck) && (sheet.duck?.regions?.length ?? 0) > 0;
if (needsDuck) writeDuckEnvelope(duckPath);

const report = [];

for (const stem of ['sfx', 'amb', 'music']) {
  const list = cues.filter((c) => c.stem === stem);
  if (!list.length) continue;
  const inputs = [];
  const chains = [];
  const labels = [];
  list.forEach((c, i) => {
    const t = Number(c.t);
    const end = c.end != null ? Number(c.end) : null;
    const trimStart = Number(c.trim_start || 0);
    const natural = duration(c.file) - trimStart;
    const wanted = end != null ? end - t : (c.trim_end != null ? Number(c.trim_end) - trimStart : natural);
    const len = Math.max(0.05, Math.min(wanted, total - t));
    const fadeIn = Number(c.fade_in ?? 0.005);
    const fadeOut = Number(c.fade_out ?? 0.02);
    const gain = Number(c.gain_db ?? 0);
    if (c.loop) inputs.push('-stream_loop', '-1');
    inputs.push('-i', c.file);
    const f = [`[${i}:a]aresample=${sr}`, 'aformat=channel_layouts=stereo'];
    f.push(`atrim=start=${trimStart}:duration=${len.toFixed(3)}`, 'asetpts=PTS-STARTPTS');
    if (fadeIn > 0) f.push(`afade=t=in:st=0:d=${Math.min(fadeIn, len).toFixed(3)}`);
    if (fadeOut > 0) f.push(`afade=t=out:st=${Math.max(0, len - fadeOut).toFixed(3)}:d=${Math.min(fadeOut, len).toFixed(3)}`);
    f.push(`volume=${gain}dB`);
    const ms = Math.round(t * 1000);
    f.push(`adelay=${ms}|${ms}`);
    chains.push(`${f.join(',')}[c${i}]`);
    labels.push(`[c${i}]`);
    if (!c.loop && natural < wanted - 0.05) {
      report.push(`${c.id}: file is ${natural.toFixed(2)} s but ${wanted.toFixed(2)} s was wanted (set "loop": true or shorten "end")`);
    }
  });
  let graph = chains.join(';') + ';' + labels.join('') + `amix=inputs=${list.length}:normalize=0:duration=longest,apad=whole_dur=${total}[mix]`;
  let last = 'mix';
  const ducked = stem === 'music' && needsDuck && list.some((c) => c.duck);
  const extra = [];
  if (ducked) {
    extra.push('-i', duckPath);
    graph += `;[${list.length}:a]aresample=${sr}:filter_type=kaiser,aformat=channel_layouts=stereo[env];[mix][env]amultiply[ducked]`;
    last = 'ducked';
  }
  const outFile = join(outDir, `${stem}_track.wav`);
  const cmd = ['-y', '-v', 'error', ...inputs, ...extra, '-filter_complex', graph, '-map', `[${last}]`, '-t', String(total), '-ar', String(sr), '-c:a', 'pcm_s24le', outFile];
  if (planOnly) {
    console.log(`ffmpeg ${cmd.join(' ')}`);
  } else {
    run('ffmpeg', cmd);
    console.log(`wrote ${outFile} (${list.length} cue${list.length > 1 ? 's' : ''}${ducked ? ', ducked under speech' : ''})`);
  }
}

if (!planOnly) {
  // One preview mix of the stems, without voice.
  const stems = ['sfx', 'amb', 'music'].map((s) => join(outDir, `${s}_track.wav`)).filter((p) => existsSync(p));
  if (stems.length) {
    const outFile = join(outDir, 'sound_preview.wav');
    const inArgs = stems.flatMap((p) => ['-i', p]);
    run('ffmpeg', ['-y', '-v', 'error', ...inArgs, '-filter_complex', `amix=inputs=${stems.length}:normalize=0`, '-c:a', 'pcm_s24le', outFile]);
    console.log(`wrote ${outFile} (all stems, no voice)`);
  }
}
for (const line of report) console.warn('warning: ' + line);

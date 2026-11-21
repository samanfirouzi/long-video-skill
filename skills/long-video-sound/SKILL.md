---
name: long-video-sound
description: Create the sound effects, ambience and background music for the video and place them on the timeline. Plans the sound design from the approved script, sources or makes each sound (Openverse for openly licensed recordings and music, Earshot to make sounds from words and to listen to and judge sounds, Clipwing real-sfx to place real sounds on exact frames), records licences and credits, and mixes separate stems (effects, ambience, music) with the music ducked under speech. Or gives the user a folder, file names and a cue table to fill. Use after long-video-voice, or when the user asks for sound effects, SFX, foley, ambience, background music or a soundtrack.
---

# Long video sound

Stage 8 of the long video workflow. Output: sound files with fixed names, a cue sheet that places them on the timeline, and separate stems (effects, ambience, music) ready for the final mix. Plus a credits file for every licensed sound.

A **scene** means one clip of the script, numbered in order across the video, as in the earlier stages.

Claude cannot hear. Say what was checked by measurement, by tags and by metadata, and ask the user to listen to key moments. Never claim a sound "sounds right" without saying how that was checked.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. Require `video-script.md` with `status: approved` and `film-style.md`.
2. Load the project config: `audio.music`, `audio.sound_effects`, budget, approval level, platform. Check `providers` for a saved music or sound method.
3. Look for `audio/lines/` (voice from `long-video-voice`) and `clips/`. Real durations make the timeline exact. If they are missing, use the durations from the script and say so.
4. If `sound/` already exists, ask: continue (list what is done), or restart.

## Step 1: What does the video need?

Work it out, then ask. Check the config (`audio.music`, `audio.sound_effects`), the genre and mood of the story, and the film style. Recommend, with a reason. Example: "A calm documentary with a narrator. I recommend a quiet music bed, ambience for the three main places, and a few effects for the doors and footsteps. No loud effects."

Ask the user to confirm three choices:

- **Background music**: yes or no.
- **Ambience** (the sound of each place): yes or no.
- **Spot effects** (footsteps, doors, whooshes): yes or no, and how many (few, normal, many).

Nothing wanted: set `"stage": "sound-skipped"` in `project.json` and stop.

## Step 2: Check the tools

Read `references/tools.md`. Check what is available and report in a short list. Never install anything without asking, and say the size first.

| Tool | Used for | Check |
|------|----------|-------|
| ffmpeg and Node | Cutting, placing, mixing, measuring (required) | `ffmpeg -version`, `node --version` |
| Openverse | Finding openly licensed sound effects and music, with licence data | Credentials in `OPENVERSE_CLIENT_ID` and `OPENVERSE_CLIENT_SECRET` (print only "set" or "not set") |
| Earshot | Making sounds from words, building missing sounds, listening and judging sounds | `earshot doctor`, or `python -c "import earshot"` |
| Clipwing real-sfx | Placing real sounds on exact frames, mixing, critique | Folder `~/.claude/skills/real-sfx/` exists |
| A music generator | Making background music from a description | A connected tool or skill that generates music |
| A video editor with a CLI or MCP (FilmCraft, EffectCraft, or any other) | Placing sound on a real timeline, ducking, loudness meters, previews | `filmcraft-cli commands`, `effectcraft-cli --help`, or a connected editing MCP server in this session |

Each tool is optional. Use the ones that are available and that the user agrees to. If none is available, use the manual path (Step 7).

## Step 3: Build the timeline

1. Read the script and list every scene with its start time, end time and length, in order. Use real durations from `clips/` and `audio/lines/` when they exist (`ffprobe`), otherwise the script's durations.
2. Add for each scene: the location id, the mood, whether it has speech and the speech start and end inside the scene.
3. Save `sound/timeline.json`. Total length = the sum of the scenes.
4. Work out the speech regions (start and end of every spoken line on the timeline). They drive the music ducking.

## Step 4: Sound design plan (the user approves it)

Read `references/sound-design.md`. Write `sound/design.md` with:

**Music plan.** Style, mood, tempo, instruments, no vocals unless asked, and an arc across the video (opening, build, peak, resolve, ending). Give 3 to 4 options for the user to choose from, each with a one-line reason. State where the music is silent, and where it ducks.

**Ambience plan.** One bed per location: what it is, which scenes it covers.

**Spot effects plan.** A cue table: scene, time inside the scene, what happens in the picture, the sound, and how it is sourced. Follow the restraint rule: a sound belongs where something happened that a person should notice. Most moments get none.

Show the plan as a summary table and the music options. Ask the user to approve or change it. Loop until the user says an explicit yes.

## Step 5: Source or make each sound

Find a sound for every cue. Choose the method in this order, by what fits:

1. **Earshot `make`** for things it has (footsteps, doors, UI, water, wind, rain, fire, crowds, whooshes, many more). Ask in words. Make several takes for repeated sounds.
2. **Openverse** for real recordings and for music. Search with the licence filters in `references/tools.md`. Take only licences that allow commercial use and changes. Reject NC and ND. Record every choice.
3. **Earshot `build`** for a sound that no catalogue has, made from recorded parts.
4. **A music generator**, if connected, for background music from the approved description.
5. **The user's own files**, if they have them.

Understand a sound before using it. With Earshot's listen tools: `match` or `rank` a candidate against the description, `find` the best moment in a long recording, `realness` for a recording, `describe` for tags. Without them, use Openverse metadata and `ffprobe` and `ffmpeg` measurements (duration, loudness, silence). Say which checks were done.

Downloading: **ask first.** List the files to download, their sources and licences, and the total size. Get one clear yes for the batch. Then download to `sound/sources/`.

Rules:

- Never use a sound whose licence is unknown, NC or ND.
- Keep every source file untouched in `sound/sources/`. Make trimmed and processed copies in `sound/cut/`.
- Name the files in `sound/cut/` by the naming rule below.
- Write `sound/credits.md` and `sound/licences.json` as you go (format in the sound design reference). One row per used sound: title, creator, licence and version, source URL, required credit text.
- Never put a real person's voice or a trademarked sound into the video without the licence to do so.

### File names (fixed)

- Spot effect: `sound/cut/scene-<NNN>_sfx_<NN>_<label>.wav`
- Ambience bed (named by its first scene): `sound/cut/scene-<NNN>_amb_<NN>_<label>.wav`
- Music: `sound/cut/music_<NN>_<label>.<ext>`

`<NNN>` is the scene number padded to 3 digits, `<NN>` the order, `<label>` lowercase words joined by hyphens. Examples: `scene-007_sfx_01_door-close.wav`, `scene-001_amb_01_sea-wind.wav`, `music_01_main-theme.mp3`. The cue sheet and the credits refer to these names.

## Step 6: Place the sounds and mix

1. Write `sound/cues.json`: one cue per placed sound, with the absolute time on the timeline, the stem (`sfx`, `amb`, `music`), the file, the gain, the fades, and the ducking choice. The format is in `scripts/mix-cues.mjs` (header comment) and in the sound design reference. Add the speech regions under `duck.regions`.
2. Time inside a scene comes from the script and the clip prompt: the moment the action happens. Mark times that are estimates. If the rendered video exists, check them against the picture.
3. Mix with the bundled script:

```
node <skill folder>/scripts/mix-cues.mjs sound/cues.json sound/mix
```

   It writes `sfx_track.wav`, `amb_track.wav`, `music_track.wav` (ducked under speech), and `sound_preview.wav` (all stems, no voice). Add `--plan` to print the ffmpeg commands without running them.

3b. If a video editor with a CLI or MCP is available (FilmCraft, EffectCraft or another, see `references/tools.md`) and the project already has a timeline with the clips, the sounds can be placed there instead, so the user can see and adjust them. Use the editor's own command list and docs first. Keep the same file names and stems, and still write `sound/cues.json` as the record. Ask the user before building or changing an editor project.
4. If Clipwing real-sfx is installed and the cues are motion-graphic type cues (whooshes, hits, risers, clicks, typing), it can place those from its own library instead. Read its `SKILL.md` and use its `--help` before running anything. Keep the same file and stem naming.
5. Measure the stems: loudness and true peak with `ffmpeg -af loudnorm=print_format=json` (or `ebur128`), clipping with `astats`. Targets are in the sound design reference. Fix levels in `cues.json`, not by editing the audio by hand.
6. If Earshot is installed, run `earshot timeline` on `sound_preview.wav` (with the video and the cue list if they exist) and `critique`, and report the findings in plain words.
7. The voice is not mixed in here. The final mix of voice, music and effects happens in the assembly stage. Keep all stems separate.

## Step 7: Manual path (the user makes or finds the sounds)

Use when no tool is available or the user prefers to do it.

1. Create `sound/cut/` and show its full path.
2. Write `sound/design.md` with every cue and its exact file name, and a short description of the sound to find or make. Include music options. Include a licence reminder: commercial use allowed, no NC or ND, keep the credit text.
3. Ask: **all at once, or one by one**.
   - **All at once.** Show the path and the cue table. The user works through it.
   - **One by one.** Show the first sound to find, with its file name. Wait for the user to say it is saved. Check the file exists, then measure duration and loudness. Show the next.
4. When the files are in place, continue with Step 6.
5. Offer to check the folder at any time: compare files against the cue table and list what is missing or misnamed.

## Step 8: Review, save, finish

1. Show a summary: number of cues by stem, music tracks and where they play, total length against the video length, loudness of each stem, the licences used.
2. Ask the user to listen to two or three key moments (the opening, a speech scene with music, the peak) in `sound_preview.wav` or by playing the stems. Ask for changes. Apply them in `cues.json` and mix again. Loop until the user approves.
3. Keep `sound/status.md` current (cue, file, status: `pending`, `done`, `needs-manual`).
4. Update `project.json`: `"stage": "sound-done"` and the paths of the stems and the credits.
5. Tell the user the paths of `sound/mix/` and `sound/credits.md`. Say the credit text must go into the video description.
6. Offer to save the working tools in the config (`providers.music`, `providers.sfx`), names only, never keys.
7. Offer to continue with `long-video-render` (assembly, review render, final render). Start it only if the user agrees. Do not start any other later stage unless the user asks and that stage exists.

## Self-check before the mix

- Every approved cue has a file with the exact name, or is marked `needs-manual`.
- Every cue time is inside the video length.
- Every used sound has a row in `credits.md` with an allowed licence.
- No spot effect covers speech unless the plan says so.
- Music is ducked under speech, and music has a fade in and a fade out.
- Stems are not clipped and match the video length.

## Rules

- Never install a tool without asking and stating the size.
- Never download without a clear yes that names the files and sources.
- Never use unlicensed, NC or ND sounds.
- Never bypass a bot check or CAPTCHA on a sound site. Use the API with the user's own credentials, or ask the user to download the file.
- Never ask for API keys or client secrets in chat. Check only whether the environment variable is set.
- Never claim a sound was heard. State what was measured or tagged.
- Keep chat messages short. Put the full plan and cue table in files.

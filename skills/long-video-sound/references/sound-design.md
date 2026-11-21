# Sound design guide

## 1. When a sound belongs

- A sound belongs where something happened that a person should notice without looking.
- Most moments get none. Restraint sounds professional. Wall-to-wall effects tire the ear.
- Every effect is caused by something in the picture (or a clear off-screen cause). No effect without a reason.
- Never put an effect on top of speech unless the plan says so. Narration and dialogue come first.
- Use one palette: sounds from the same world (same room tone, same material) fit together.
- Repeated actions (footsteps, knocks) need several takes, so the repetition does not sound mechanical.

Effect density guide for the "how many" choice:

| Choice | Roughly |
|--------|---------|
| few | One spot effect in every 3 to 5 scenes, only for key actions and transitions |
| normal | One in every 1 to 2 scenes |
| many | Most scenes have one or more, for action-heavy or comedy styles |

## 2. Layers

| Stem | What | Level (starting point) |
|------|------|------------------------|
| `amb` | Ambience: the sound of the place, a bed that runs under a location | -26 to -32 dB gain on a normalized file, quiet |
| `sfx` | Spot effects and transitions | Peaks about -6 dBFS; quiet effects lower |
| `music` | Background music | About -20 to -24 dB gain, ducked 8 to 12 dB under speech |

Final loudness is set in the assembly stage, with voice. A common target for online video is about -14 LUFS integrated with true peak below -1 dBTP. Narration should sit clearly above music: music about 15 to 20 LU below the voice while speech plays.

## 3. Music plan

Decide with the user:

- Style and mood (calm, tense, warm, epic, playful), tempo range, instruments, no vocals unless asked.
- The arc over the video, as sections with time ranges from the timeline: opening, build, peak, resolve, ending. The peak lands on the story's key moment.
- Entrances and exits: fade in over 2 to 4 seconds, fade out over 4 to 8 seconds at the end.
- Silence on purpose: reveals and emotional beats often play better without music.
- One track, or several that cross-fade. For a long video, two or three tracks of the same family beat one track on loop.
- Do not loop a short track that is obviously repeating. Prefer a long enough track or several tracks.

Offer 3 to 4 options, each: style, mood, tempo, instruments, source (Openverse search, generator, user file), and why it fits.

## 4. Ambience plan

One bed per location in the visual bible. For each: the sound (sea and gulls, night wind, a quiet room), the scenes it covers, and level. Beds fade in and out at location changes (1 to 2 seconds), and may overlap during a dissolve.

## 5. Spot cue table (in `sound/design.md`)

```
| Scene | At (s in scene) | Picture event | Sound | Source | File | Gain |
|-------|-----------------|---------------|-------|--------|------|------|
| 007 | 0.5 | Mara closes the lighthouse door | wooden door closing | earshot make | scene-007_sfx_01_door-close.wav | -6 dB |
```

Get "At" from the script and the clip prompt (the action timeline). Estimates are marked `~`.

## 6. Cue sheet (`sound/cues.json`)

Read by `scripts/mix-cues.mjs`.

```json
{
  "total_seconds": 612.5,
  "sample_rate": 48000,
  "duck": { "db": 10, "ramp": 0.35, "regions": [[2.0, 8.1], [9.0, 14.2]] },
  "cues": [
    { "id": "sfx-007-01", "stem": "sfx", "file": "sound/cut/scene-007_sfx_01_door-close.wav",
      "t": 41.2, "gain_db": -6, "fade_in": 0.01, "fade_out": 0.1 },
    { "id": "amb-001-01", "stem": "amb", "file": "sound/cut/scene-001_amb_01_sea-wind.wav",
      "t": 0, "end": 60, "gain_db": -28, "fade_in": 2, "fade_out": 2, "loop": true },
    { "id": "mus-01", "stem": "music", "file": "sound/cut/music_01_main-theme.mp3",
      "t": 0, "end": 612.5, "gain_db": -20, "fade_in": 3, "fade_out": 6, "loop": false, "duck": true }
  ]
}
```

| Field | Meaning |
|-------|---------|
| `t` | Start time on the whole-video timeline, in seconds |
| `end` | End time for beds and music. Without it the file plays to its own end |
| `trim_start` | Seconds cut from the start of the file |
| `gain_db` | Level change in dB |
| `fade_in`, `fade_out` | Fade lengths in seconds |
| `loop` | Repeat the file to fill `t` to `end` |
| `duck` | Music only: lower this cue while a speech region is active |

`duck.regions` are the speech time spans (start, end) on the whole-video timeline, from `audio/lines/` durations and the scene start times. `db` is how far the music drops, `ramp` is the fade time into and out of the dip.

Absolute time = the scene's start time on the timeline + the time inside the scene.

## 7. Checks

Loudness and true peak of a stem:

```
ffmpeg -hide_banner -i sound/mix/music_track.wav -af ebur128=peak=true -f null -
```

Clipping and levels:

```
ffmpeg -hide_banner -i sound/mix/sfx_track.wav -af astats=metadata=0 -f null -
```

Silence and gaps:

```
ffmpeg -hide_banner -i sound/mix/amb_track.wav -af silencedetect=noise=-50dB:d=2 -f null -
```

Look for: peaks above -1 dBFS (clipping), a stem shorter or longer than the video, long unplanned silence in a bed, music not dipping under speech.

## 8. Credits and licence files

`sound/licences.json`:

```json
[
  {
    "file": "sound/cut/music_01_main-theme.mp3",
    "title": "Track title",
    "creator": "Creator name",
    "licence": "CC BY",
    "licence_version": "4.0",
    "source": "openverse",
    "source_url": "https://...",
    "credit": "\"Track title\" by Creator name, licensed CC BY 4.0, via Openverse"
  }
]
```

`sound/credits.md`: a plain list of every credit line, ready to paste into the video description. Sounds made by Earshot or a generator get a line saying so, if the tool's terms ask for it.

## 9. Naming recap

- `scene-<NNN>_sfx_<NN>_<label>.wav`
- `scene-<NNN>_amb_<NN>_<label>.wav`
- `music_<NN>_<label>.<ext>`

Lowercase, hyphens inside the label. The cue sheet, credits and status file use the same names.

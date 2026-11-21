# Edit list format

`render/edl.json` is read by `scripts/build-render.mjs`. Paths are relative to the project folder (run the script from there) or absolute.

```json
{
  "title": "How the Sea Became Salty",
  "slug": "sea-salty",
  "fps": 24,
  "width": 1920,
  "height": 1080,
  "captions_mode": "burn",
  "voice_gain_db": 0,
  "loudness": { "i": -14, "tp": -1.5, "lra": 11 },
  "review": { "height": 360, "crf": 32, "preset": "veryfast", "audio_bitrate": "96k" },
  "final": { "crf": 18, "segment_crf": 14, "preset": "slow", "audio_bitrate": "192k" },
  "scenes": [
    { "n": 1, "duration": 6.0,
      "visual": { "type": "clip", "file": "clips/scene-001_clip.mp4", "trim_start": 0 },
      "transition_out": "cut" },
    { "n": 2, "duration": 7.0,
      "visual": { "type": "image", "image": "frames/scene-002_start.png", "move": "push-in" },
      "transition_out": "fade" }
  ],
  "voice": [
    { "file": "audio/lines/scene-001_narrator_01.mp3", "t": 0.3, "gain_db": 0 }
  ],
  "stems": [
    { "file": "sound/mix/sfx_track.wav", "gain_db": 0 },
    { "file": "sound/mix/amb_track.wav", "gain_db": 0 },
    { "file": "sound/mix/music_track.wav", "gain_db": 0 }
  ],
  "captions": [
    { "start": 0.3, "end": 5.1, "text": "You think you know why the sea is salty." }
  ]
}
```

## Fields

| Field | Meaning |
|-------|---------|
| `slug` | Used in output file names |
| `fps`, `width`, `height` | From the config. Defaults 24 fps, 1920x1080 |
| `captions_mode` | `burn` (burned into the picture), `srt` (separate file), `none` |
| `voice_gain_db` | Level change for the whole voice track |
| `loudness` | Target integrated loudness, true peak and loudness range |
| `review` | Review quality: output height (width follows the aspect ratio), crf (higher is smaller and worse), preset, audio bitrate |
| `final` | Final quality: crf, segment crf (the intermediate scene files), preset, audio bitrate |

### Scenes

| Field | Meaning |
|-------|---------|
| `n` | Scene number (same as in file names) |
| `duration` | Seconds, from the approved script. Scene start times are the running sum |
| `visual.type` | `clip` or `image` |
| `visual.file` | The clip (type `clip`) |
| `visual.trim_start` | Seconds skipped at the start of the clip |
| `visual.image` | The still (type `image`), normally the start frame |
| `visual.move` | For stills: `push-in`, `pull-out`, `pan-left`, `pan-right`, `none` |
| `transition_out` | `cut` (default) or `fade` (dip to black, 0.4 s out of this scene and in to the next) |

A clip longer than `duration` is cut at the end. A clip shorter than `duration` holds its last frame. The clip is scaled to fill the frame and cropped to the aspect ratio.

### Voice, stems, captions

- `voice[].t` is the absolute start time on the video timeline: scene start plus an offset.
- Stems are placed at time 0 and must be as long as the video. `mix-cues.mjs` from `long-video-sound` writes them that way. Music is already ducked in its stem.
- `captions[]` use absolute times. Text should be the narration text unchanged. Keep each caption short enough for two lines.

## What the script does

1. Checks the files and the plan, and reports warnings (a voice line over its scene, a clip too short).
2. Renders each scene to its own file in `work_<mode>/segments/` and caches them by content. A later render redoes only the scenes that changed.
3. Joins the segments without re-encoding.
4. Builds the voice track and mixes it with the stems. Review: one-pass loudness. Final: two-pass loudness with linear gain.
5. For review, burns the scene label and time. With `captions_mode: burn`, burns captions.
6. Writes the MP4 and a `.report.json` (duration, size, streams, loudness, warnings).

Limits of the bundled renderer: cuts and dip-to-black only (no cross-dissolves), simple camera moves on stills, no titles or effects. Use an editor tool for more.

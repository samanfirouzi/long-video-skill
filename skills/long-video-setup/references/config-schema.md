# Config schema

File: `~/.long-video/configs/<config-name>.json`

Rules:

- `schema_version` is required. Current value: 1.
- Never store secret values. Store the environment variable name only.
- Unknown fields are kept when a config is edited.

## Example

```json
{
  "schema_version": 1,
  "name": "youtube-explainer-en",
  "saved": "2026-11-19",
  "video": {
    "format": "explainer",
    "target_length_min": 15,
    "language": "en",
    "platform": "youtube",
    "aspect_ratio": "16:9",
    "resolution": "1080p",
    "fps": 24,
    "max_clip_seconds": 10,
    "preferred_clip_seconds": [5, 8]
  },
  "audience": {
    "description": "curious beginners",
    "tone": "friendly",
    "point_of_view": "narrator"
  },
  "visuals": {
    "approach": "ai-images",
    "art_direction": "flat illustration, warm colors",
    "captions": "burned-in"
  },
  "audio": {
    "voiceover": {
      "source": "cloud-tts",
      "provider": "elevenlabs",
      "voice": "calm narrator",
      "speed": 1.0
    },
    "music": "royalty-free",
    "sound_effects": false
  },
  "providers": {
    "tts": { "name": "elevenlabs", "key_env": "ELEVENLABS_API_KEY" },
    "image": { "name": "openai", "key_env": "OPENAI_API_KEY" },
    "video": null,
    "stock": null
  },
  "workflow": {
    "approval": "every-stage",
    "budget": "ask-before-paid-steps",
    "output_root": "~/.long-video/projects"
  },
  "channel": null,
  "notes": ""
}
```

`channel` is optional. The publish stage fills it with the channel name, niche, title style, call to action, links, default tags and a description footer, so the next video starts with the same packaging. See `long-video-publish/references/youtube-metadata.md` for the shape.

## Field notes

| Field | Allowed values |
|-------|----------------|
| `video.fps` | Frames per second of the final video. Default 24 |
| `video.max_clip_seconds` | Whole number. Longest allowed single shot or clip. Default 10 |
| `video.preferred_clip_seconds` | Two numbers `[min, max]`. Default `[5, 8]` |
| `video.format` | explainer, documentary, storytelling, tutorial, other |
| `visuals.approach` | stock, ai-images, ai-video, animation-2d, slideshow, screen-recording, mixed |
| `visuals.captions` | burned-in, subtitle-file, none |
| `audio.voiceover.source` | cloud-tts, local-tts, self-recorded, none |
| `audio.music` | none, generated, royalty-free, own-files |
| `workflow.approval` | every-stage, story-and-final, automatic |

Set unused provider entries to `null`.

### Image generation method

`providers.image` may also record how images are generated, so the next run skips discovery:

```json
"image": {
  "method": "mcp",
  "name": "creative-mcp",
  "key_env": null,
  "browser_site": null,
  "supports_reference": true
}
```

`providers.tts` uses the same shape, plus `languages` (supported languages) and `can_design_voice`.

`providers.video` uses the same shape, plus `supports_end_image`, `max_clip_seconds` and `has_own_audio`.

`method` values: `api`, `mcp`, `local`, `browser`, `none`. For `browser`, set `browser_site` to the site name (never credentials). `supports_reference` says whether the method accepts a reference image, which character sheets need.

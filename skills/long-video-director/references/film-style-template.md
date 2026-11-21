# Film style template

Save as `film-style.md` in the project folder. The same format is used for presets in `~/.long-video/film-styles/<preset-name>.md`.

Fill every field. Use "none" where a field does not apply. Use plain words. Later stages read this file, so keep names and ids exact.

````markdown
---
name: <preset or project name>
saved: <ISO date>
project: <project slug or "preset">
speaking_mode: narrator | characters | mixed
art_style_locked: true | false
---

# Film style: <name>

## Speaking
- Mode: <narrator | characters | mixed>
- Narrator voice: <description, provider and voice if known, or "none">
- Character voices:
  - <char-id>: <voice description, provider and voice if known>
- Characters shown speaking: <on screen with lip-sync | off-screen delivery | mouths hidden | not applicable>

## Art style (copied from visual-bible.md, do not edit here)
STYLE_BLOCK:
<exact text>

NEGATIVE:
<exact text>

## Camera and format
- Look: <choice>
- Why: <one line tied to the story>

## Lenses and framing
- Main lenses: <list>
- Default framing: <choice>
- Angles used: <list, and when>

## Camera movement
- Default movement: <choice>
- Allowed movements: <list>
- Avoid: <list>
- Notes on production: <what the user's tools can do>

## Lighting
- Default: <choice>
- Variants by scene type:
  - <scene type>: <lighting>

## Color and grade
- Grade: <choice>
- Palette notes: <hex codes from the style block where useful>

## Pacing and transitions
- Clip length limit: max <10> s, preferred <5 to 8> s
- Average shot length: <seconds, inside the preferred range>
- Rhythm over time: <for example slow open, steady middle, brisk build, slow end>
- Default transition: <choice>
- Other transitions allowed: <list>

## Prompt line for generators
One block of text, 2 to 3 sentences, that later stages append to image or video prompts to carry the camera and lighting look. It must not contradict the art style block.
````

## Notes

- The art style block is copied exactly from `visual-bible.md`. It stays the single source of art style.
- The "prompt line for generators" is a short text that adds camera, lens and lighting words. Example: "Cinematic wide shot, soft overcast daylight, shallow depth of field, slow push-in feel."
- If the art style is not locked, set `art_style_locked: false` and put the user's short description in place of the style block.

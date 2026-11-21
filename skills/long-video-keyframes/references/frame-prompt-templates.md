# Frame prompt templates

Fill the placeholders. Copy `{STYLE_BLOCK}`, `{NEGATIVE}` and `{FILM_LINE}` exactly. Copy entity descriptions exactly from `visual-bible.md`.

## Start frame prompt

```
[scene-{NNN} / start frame / script shot {S.S} / save as: frames/scene-{NNN}_start.png]
References to attach: {list of files, for example images/char-mara_02_sheet.png, images/env-lighthouse_environment.png, images/obj-lantern_object.png}

The first frame of a {DURATION}-second clip.
Picture: {WHAT WE SEE at the first frame: who is where, doing what, facing which way, expression}.
Characters: {CHARACTER NAME}: {DESCRIPTION from the visual bible, verbatim}.
Place: {ENVIRONMENT NAME}: {DESCRIPTION from the visual bible, verbatim}. {Time of day, weather}.
Objects: {OBJECT NAME}: {DESCRIPTION, verbatim}. {Where it is, who holds it}.
Camera: {SHOT SIZE}, {ANGLE}, {LENS}. Composition: {where the subject sits in the frame}.
Lighting: {LIGHTING from the shot and film style}.
{FILM_LINE}
{STYLE_BLOCK}
Avoid: {NEGATIVE}. No text, captions or logos in the picture.
Aspect ratio: {FRAMING}
```

## End frame prompt

```
[scene-{NNN} / end frame / script shot {S.S} / save as: frames/scene-{NNN}_end.png]
References to attach: frames/scene-{NNN}_start.png (first), then {the other reference files}

The last frame of the same {DURATION}-second clip, using the start frame as the reference.
Same place, same characters, same objects, same art style, same lighting setup.
What changes between the start and the end: {camera movement result, for example "the camera has pushed in from a medium shot to a close-up of the lantern"} and {action result, for example "Mara has raised the lantern and is looking up"}.
Picture: {WHAT WE SEE at the last frame}.
Characters: {CHARACTER NAME}: {DESCRIPTION, verbatim}.
Place: {ENVIRONMENT NAME}: {DESCRIPTION, verbatim}.
Objects: {OBJECT NAME}: {DESCRIPTION, verbatim}.
Camera: {SHOT SIZE}, {ANGLE}, {LENS}. Composition: {where the subject sits in the frame}.
Lighting: {LIGHTING at the end, including any change}.
{FILM_LINE}
{STYLE_BLOCK}
Avoid: {NEGATIVE}. No text, captions or logos in the picture.
Aspect ratio: {FRAMING}
```

## Continuation scene

A continuation scene (script says `Continues:`) has no start prompt. Its start frame is the previous scene's end frame. Write only the end prompt. In its header, add:

```
Start frame: frames/scene-{PREVIOUS}_end.png (reused, do not generate)
```

## Static shots

If the camera and the subject do not move, the end frame shows the same composition with one small natural change: a gesture, a blink, a light shift, drifting mist. Say what it is. Do not leave the end frame identical to the start frame.

## File names

| Frame | Name |
|-------|------|
| Start | `scene-{NNN}_start` |
| End | `scene-{NNN}_end` |

`{NNN}` is the scene number padded to 3 digits (4 digits if the video has more than 999 scenes). Lowercase only. Use the extension the generator produces. Never change a name after the prompts are approved.

## Batch files

`frame-prompts/scenes-001-020.md`, `scenes-021-040.md`, and so on. Each file starts with a short header:

```
# Frame prompts: scenes 001 to 020
Folder for the images: <full path>/frames/
Name rule: scene-<number>_start / scene-<number>_end
```

Then each scene as a heading, followed by its start prompt and its end prompt.

## Index

`frame-prompts/index.md`:

```
| Scene | Script shot | Frame | File | References | Status |
|-------|-------------|-------|------|------------|--------|
| 001 | 1.1 | start | frames/scene-001_start.png | char-mara_02_sheet, env-lighthouse_environment | pending |
| 001 | 1.1 | end | frames/scene-001_end.png | scene-001_start, char-mara_02_sheet | pending |
| 002 | 1.2 | start | frames/scene-001_end.png (reused) | none | reused |
| 002 | 1.2 | end | frames/scene-002_end.png | scene-001_end, char-mara_02_sheet | pending |
```

## Consistency checklist

- Same style block, negative terms and film line in every prompt, character for character.
- Same description text for an entity wherever it appears.
- Same aspect ratio everywhere.
- Every prompt lists its reference files with exact names.
- Start and end frames agree on place, characters and light, and differ as the shot says.
- No "same as above".

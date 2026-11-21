# Voice script format

## File names

```
audio/lines/scene-<NNN>_<speaker>_<NN>.<ext>
```

- `<NNN>`: the scene number, padded to 3 digits (4 if the video has more than 999 scenes). Same number as in `frames/` and `clips/`.
- `<speaker>`: `narrator`, or the character id without the `char-` prefix.
- `<NN>`: the order of the line inside the scene, starting at 01.
- Any extension works (mp3, wav). The base name must match. Lowercase only.

Examples:

- `audio/lines/scene-007_narrator_01.mp3`
- `audio/lines/scene-012_mara_01.mp3`
- `audio/lines/scene-012_tomas_02.mp3`

Voice samples: `audio/samples/sample_<speaker>.mp3`.

A scene with no speech has no file. The index marks it "no speech".

## Building the line list

1. Read the approved script in order.
2. Every `Narration:` text becomes lines for `narrator`. Every `CHARACTER: line` becomes a line for that character.
3. If a shot has several sentences, keep them as one line when one breath carries them. Split at a natural pause if the line would run over about 10 seconds.
4. Keep the words exactly as in the script. Do not edit.
5. Add a delivery note from the script's parentheses (for example "quiet, tired"). If missing, leave it blank. Do not invent big emotions.
6. Add pronunciation notes for names, numbers, abbreviations and foreign words (for example "write 1912 as nineteen twelve"). Put the spoken form in the note and keep the script text unchanged.

## Line list entry

```
### scene-007_narrator_01
File: audio/lines/scene-007_narrator_01.mp3
Speaker: narrator (voice: <description or voice name>)
Scene length: 6.0 s   Target speech length: up to 5.5 s
Delivery: calm, curious
Pronunciation: none
Text:
"You think you know why the sea is salty. But have you ever asked who first measured it?"
```

## Fit rules

Compare the audio duration with the scene duration from the script.

| Result | Action |
|--------|--------|
| Audio is up to the scene length minus 0.5 s | Fits. Mark `ok` |
| Audio is between the scene length minus 0.5 s and the scene length | Tight. Mark `tight`. Fine for narration, check it |
| Audio is longer than the scene | Mark `too-long`. Ask the user: faster delivery (at most 10 percent), a longer scene (never above the 10 second limit), or split the line across two scenes |
| Audio is much shorter than the scene (under 50 percent) | Mark `short`. Fine if the scene carries a visual beat. Tell the user |

Never change the words to make a line fit without asking.

## Batch files

`voice-scripts/scenes-001-020.md`, and so on. Header:

```
# Voice lines: scenes 001 to 020
Folder for the audio: <full path>/audio/lines/
Name rule: scene-<number>_<speaker>_<line number>
Voices: <speaker: voice description, one per line>
```

Then each line as an entry.

## Index

`voice-scripts/index.md`:

```
| Scene | Speaker | Line | File | Scene length | Status |
|-------|---------|------|------|--------------|--------|
| 001 | narrator | 01 | audio/lines/scene-001_narrator_01.mp3 | 6.0 s | pending |
| 002 | narrator | 01 | audio/lines/scene-002_narrator_01.mp3 | 7.0 s | pending |
| 003 | no speech | | | 5.0 s | n/a |
```

## Status file

`audio/status.md`:

```
| Scene | Speaker | File | Status | Audio length | Scene length | Fit | Note |
|-------|---------|------|--------|--------------|--------------|-----|------|
| 001 | narrator | scene-001_narrator_01.mp3 | done | 5.1 s | 6.0 s | ok | |
| 002 | narrator | scene-002_narrator_01.mp3 | needs-manual | | 7.0 s | | mispronounced name twice |
```

Status values: `pending`, `done`, `needs-manual`, `skipped`. Fit values: `ok`, `tight`, `too-long`, `short`.

At the top of the file, add a line with the total spoken time and the total video time.

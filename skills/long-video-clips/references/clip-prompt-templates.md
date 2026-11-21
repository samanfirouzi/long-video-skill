# Clip prompt templates

Image-to-video prompts. Fill the placeholders. Copy `{STYLE_BLOCK}`, `{NEGATIVE}` and `{FILM_LINE}` exactly. Copy entity descriptions from `visual-bible.md`.

Take the camera, lighting, action and duration from the script shot. Do not invent a different camera move.

## Full prompt

```
[scene-{NNN} / script shot {S.S} / clip prompt]
Save the clip as: clips/scene-{NNN}_clip.mp4
Start image: frames/scene-{NNN}_start.png
End image: frames/scene-{NNN}_end.png   (if the tool has no end image field, use it as a guide only)
Extra references: {character sheet, environment image, object image, exact file names}
Clip length: {SECONDS} s (tool length: {ALLOWED LENGTH} s, trim to {SECONDS} s later)   Aspect ratio: {FRAMING}   Resolution: {RESOLUTION}

SHOT
{SHOT SIZE}, {ANGLE} angle, {LENS} lens. {DEPTH OF FIELD, for example shallow, background softly blurred}.

CAMERA MOVEMENT
{MOVE} from {START POSITION} to {END POSITION}, {SPEED: very slow, slow, steady, fast}, {SMOOTHNESS: smooth and stabilized, or handheld with gentle sway}. The movement lasts the full clip and finishes on the end image.

ACTION (timeline)
0 to {T1} s: {what happens}.
{T1} to {T2} s: {what happens}.
{T2} to {SECONDS} s: {what happens, ending as in the end image}.
Subject movement: {how big and how fast, for example small, calm, natural}.

SUBJECTS
{CHARACTER NAME}: {DESCRIPTION, verbatim}. Stays exactly as in the start image: same face, hair, clothing, proportions and colors.
{OBJECT NAME}: {DESCRIPTION, verbatim}.
Place: {ENVIRONMENT NAME}: {DESCRIPTION, verbatim}. {Ambient motion, for example mist drifting, leaves moving, water rippling}.

LIGHTING
{LIGHTING TYPE and DIRECTION}, {COLOR TEMPERATURE}. {Change during the clip, if any, for example the lantern light grows warmer}. Shadows: {soft or hard}.

STYLE
{FILM_LINE}
{STYLE_BLOCK}

CONSISTENCY
Keep the art style, palette, characters, set and lighting identical to the start image for the whole clip. No new characters, no new objects, no text, no cuts inside the clip, no flicker, no morphing.

SPEECH
{one of the three lines below}

NEGATIVE
{NEGATIVE}, warped faces, extra fingers, melting objects, sudden style change, flicker, text, subtitles, watermark, camera shake (unless handheld is asked)
```

## Speech line (use one)

- Narrator video (the speaking mode is narrator): `No speech and no lip movement. Characters keep their mouths closed. Silent clip; the voiceover is added later.`
- Characters speak, tool has lip-sync or speech: `{CHARACTER} says: "{LINE}" ({DELIVERY NOTE}). Lips match the words. Voice: {VOICE DESCRIPTION}. Only this speech, no other voices.`
- Characters speak, tool has no speech: `The character speaks, mouth moving naturally, but no audio is generated. The voice is added later.` If the production cannot show mouth movement, use the mouths-hidden choice from `film-style.md`.

## Short version

Many tools limit the prompt length. Add this line under the full prompt, at most 300 characters:

```
Short: {SHOT SIZE}, {ANGLE}, {MOVE} {SPEED}; {ONE-LINE ACTION}; {LIGHTING}; {STYLE in 6 words}; keep characters identical, no text.
```

## Camera words that video tools understand

Use these exact phrases. Pick the ones from the shot. Say speed and where the move ends.

| Script move | Phrase for the prompt |
|-------------|-----------------------|
| Static | "static locked-off camera, no camera movement" |
| Slow push-in | "slow smooth dolly in toward the subject" |
| Pull-out | "slow smooth dolly out, revealing the surroundings" |
| Pan | "slow pan left to right" or "right to left" |
| Tilt | "slow tilt up" or "tilt down" |
| Tracking | "tracking shot moving alongside the subject at walking pace" |
| Handheld | "handheld camera with gentle natural sway" |
| Crane | "crane shot rising up and back" or "descending" |
| Orbit | "slow orbit around the subject, 45 degrees" |
| Rack focus | "rack focus from the foreground to the subject" |
| Whip pan | "fast whip pan" |
| Ken Burns on a still | "very slow zoom in with slight parallax between foreground and background" |
| Virtual parallax | "layers drift at different speeds, foreground faster than background" |

Angle words: eye level, low angle looking up, high angle looking down, overhead top-down, over-the-shoulder, point of view, dutch angle (tilted).

## Lighting words

Soft overcast daylight, golden hour backlight, low-key light with deep shadows, high-key bright even light, chiaroscuro side light, lantern or candle practical light, neon mixed light, blue hour twilight, hard top light, hazy light beams. Always add direction (from the left, behind, above) and warmth (warm, neutral, cool).

## Rules for good clips

- One move per clip. One main action per clip. Do not stack a crane move, an orbit and a big action together.
- Match the duration. A 6 second clip holds one small action, not a long story.
- Keep motion modest for the best consistency: slow camera, small natural subject motion. Strong action only when the script needs it.
- The start and end images define the look. Do not describe new details that are not in them.
- State what stays unchanged. Video tools drift without this.
- No text, subtitles, or logos in the clip.
- Do not use real people's names, trademarks or living artists' names.

## Batch files

`clip-prompts/scenes-001-020.md`, and so on. Header:

```
# Clip prompts: scenes 001 to 020
Folder for the clips: <full path>/clips/
Start and end images: <full path>/frames/
Name rule: scene-<number>_clip (retakes: scene-<number>_clip_take2)
```

Then each scene as a heading with its full prompt and short version.

## Index

`clip-prompts/index.md`:

```
| Scene | Script shot | Clip file | Start image | End image | Length | Status |
|-------|-------------|-----------|-------------|-----------|--------|--------|
| 001 | 1.1 | clips/scene-001_clip.mp4 | frames/scene-001_start.png | frames/scene-001_end.png | 6 s | pending |
| 002 | 1.2 | clips/scene-002_clip.mp4 | frames/scene-001_end.png (reused) | frames/scene-002_end.png | 7 s | pending |
```

## Consistency checklist

- Same style block, negative terms and film line in every prompt.
- Entity descriptions copied exactly.
- File names exact and in the header.
- Duration at most 10 seconds and matching the script.
- Camera and lighting match the script shot and the film style.
- Speech line matches the speaking mode.

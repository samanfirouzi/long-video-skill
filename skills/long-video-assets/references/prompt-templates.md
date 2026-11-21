# Prompt templates

Fill the placeholders. Copy `{STYLE_BLOCK}` and `{NEGATIVE}` exactly from the approved style block, the same in every prompt.

Write prompts as plain descriptive sentences. If the provider's prompt format is known, adapt the wording, not the content.

## Style block format

Saved in `visual-bible.md`:

```
STYLE_BLOCK:
<medium, line quality, shading, texture, lighting, palette with hex codes, composition feel, in 2 to 4 sentences>

NEGATIVE:
<comma separated list of things to avoid>

FRAMING:
<aspect ratio from config, for example 16:9>
```

## Character prompt 1: character image

```
[{ID} / image 1 of 2 / generate first / save as: images/{ID}_01_character.png]
A full-body image of {NAME}, {DESCRIPTION: age, build, face, hair, skin, clothing with colors and materials, accessories, signature details}.
Neutral relaxed standing pose, facing the viewer, arms slightly away from the body, full body visible from head to feet.
Plain solid light-gray background, even soft lighting, no other objects, no text.
{STYLE_BLOCK}
Avoid: {NEGATIVE}
Aspect ratio: portrait 3:4
```

## Character prompt 2: character sheet

Use the approved result of prompt 1 as the reference image.

```
[{ID} / image 2 of 2 / use images/{ID}_01_character.png as reference / save as: images/{ID}_02_sheet.png]
A character sheet of the exact same character as the reference image: {NAME}, {DESCRIPTION}.
Layout: on a plain light-gray background, a clean model sheet showing
- a turnaround of the full body: front, three-quarter, side and back views, same height and same pose, in a row;
- three face close-ups: neutral, happy, and {STORY-SPECIFIC EMOTION};
- a small detail panel for {KEY OUTFIT PIECES AND PROPS};
- a color palette strip with 5 swatches taken from the character.
Keep face, proportions, outfit and colors identical in every view.
No text labels, no extra characters.
{STYLE_BLOCK}
Avoid: {NEGATIVE}
Aspect ratio: landscape 16:9
```

## Environment prompt

```
[{ID} / environment / generate after the character images / save as: images/{ID}_environment.png]
A wide establishing image of {PLACE NAME}: {DESCRIPTION: architecture or terrain, materials, scale, layout, key fixed features, colors, weather, time of day, mood}.
No people, no animals. Keep the center of the frame open so characters can be placed later.
Lighting: {DEFAULT LIGHTING}.
{STYLE_BLOCK}
Avoid: {NEGATIVE}
Aspect ratio: {FRAMING}
```

Variants (only if the story needs them): write one extra line for each, for example "Variant: same place at night, lit by lantern light." Keep every other word of the prompt the same. Give each variant its own header and file name, for example `save as: images/{ID}_environment_night.png`.

## File names

The expected file name goes in the header of every prompt, so images are never lost.

| Image | Name |
|-------|------|
| Character image | `{ID}_01_character` |
| Character sheet | `{ID}_02_sheet` |
| Environment | `{ID}_environment` |
| Environment variant | `{ID}_environment_{variant}` |
| Object | `{ID}_object` |

Use the extension the generator produces (png by default). Names use lowercase letters, digits, hyphens and underscores only. Never change a name after the prompt is approved.

## Object prompt

```
[{ID} / object / generate after the character images / save as: images/{ID}_object.png]
{OBJECT NAME}: {DESCRIPTION: shape, size relative to a human hand or body, materials, colors, wear, markings, distinctive features}.
Shown alone, centered, slightly angled view that shows its main features, on a plain light-gray background, soft even lighting, no hands, no other objects, no text.
{STYLE_BLOCK}
Avoid: {NEGATIVE}
Aspect ratio: square 1:1
```

## Index format

`prompts/index.md`:

```
| Order | ID | Type | Prompt | Reference needed | Save as | Status |
|-------|----|------|--------|------------------|---------|--------|
| 1 | char-mara | character | image 1 of 2 | none | images/char-mara_01_character.png | pending |
| 2 | char-mara | character | image 2 of 2 | char-mara_01_character | images/char-mara_02_sheet.png | pending |
| 3 | env-lighthouse | environment | 1 | none | images/env-lighthouse_environment.png | pending |
| 4 | obj-lantern | object | 1 | none | images/obj-lantern_object.png | pending |
```

Order: all character image 1 prompts, then all character sheets, then environments, then objects.

## Consistency checklist

- Same `{STYLE_BLOCK}`, `{NEGATIVE}` text in every prompt, character for character.
- Same description text for an entity in every prompt that uses it.
- Palette hex codes appear in the style block, not changed per prompt.
- No living artist, studio, brand or real person names.
- No "same as above" wording.

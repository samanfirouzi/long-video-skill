# YouTube metadata reference

Limits and rules below come from YouTube's help pages at the time of writing. They change. If something matters, check YouTube's current help before relying on it. `scripts/check-metadata.mjs` checks the limits it knows.

## Limits

| Item | Limit |
|------|-------|
| Title | 100 characters. Most places cut it near 60 to 70 |
| Description | 5,000 characters. No `<` or `>` |
| Tags | 500 characters in total, commas count |
| Hashtags | The first 3 show above the title. More than 15 and YouTube ignores all of them |
| Chapters | First timestamp `0:00`, at least 3 timestamps, each chapter at least 10 seconds |
| Thumbnail | 16:9, 1280x720 or larger (minimum width 640), JPG, PNG or GIF, under 2 MB |

## Titles

Angles to cover when writing 10 options:

1. **Question.** "Why Is the Sea Salty?"
2. **Curiosity gap.** Promise a specific answer without giving it away.
3. **Contrast.** "Everyone Thinks X. The Truth Is Y."
4. **Number or list.** "5 Things ..."
5. **Benefit.** What the viewer will understand or get.
6. **Story.** A person, place or event with a hook.
7. **Challenge to belief.** "You Have Been Told the Wrong Thing About ..."
8. **Plain keyword.** Clear, searchable, no tricks.
9. **Time or scale.** "In 10 Minutes", "After 100 Years".
10. **Emotion.** Awe, fear, surprise, honestly matched to the video.

Rules:

- Put the main keyword near the front.
- Be clear first, clever second. A viewer should know what the video is about.
- Deliver what the title promises. A mismatch lowers watch time and trust.
- Avoid all caps, repeated punctuation, misleading claims and spoilers.
- Vary the length. Show the character count next to each title.
- The title and the thumbnail work as a pair: the thumbnail shows the idea, the title says it. Do not repeat the same words in both.

## Description template

```
<Line 1: hook with the main keyword.>
<Line 2: what the viewer will learn or feel.>

<Summary: 2 to 4 natural sentences.>

Chapters
0:00 <Name>
1:10 <Name>
3:45 <Name>

<Links and call to action>

Sources
- <only verified sources>

Credits
<exact lines from sound/credits.md>

#<hashtag1> #<hashtag2> #<hashtag3>
```

Notes:

- The first 100 to 150 characters show in search and before "show more". Make them count.
- Write for people. Use the main keyword and related words naturally. Do not repeat keywords in a block.
- Chapters: derive times from the script's scene starts on the final timeline. Group scenes into 5 to 15 chapters for a long video. Names are short and clear, not spoilers when the video is a mystery.
- Credits are required by licences such as CC BY. Copy them exactly.
- If the video is non-fiction, add sources only for facts that were verified. State where claims come from.

## Tags

- 10 to 15 tags, main keyword first.
- Mix: exact phrase, close variants, topic words, 2 or 3 broad terms.
- Tags carry little ranking weight. Never stuff them or add unrelated popular terms. That breaks YouTube's spam rules.

## Thumbnail principles

- One clear focal point (a face, a creature, an object). Close and large.
- High contrast and a limited palette. Readable at 120 pixels wide.
- 0 to 4 words of text, big and simple. The text adds, it does not repeat the title.
- A clear emotion or question in the picture.
- Keep important content away from the bottom-right corner, where the timestamp sits.
- Match the video's art style so the thumbnail looks like the video. Do not show anything the video does not contain.
- Three distinct concepts, not three small variations, if a thumbnail test will be used.

### Thumbnail prompt template

```
[thumbnail_{NN}_{label} / save as: publish/thumbnail/thumbnail_{NN}_{label}.png]
References to attach: {character image and sheet file names, if used}

A YouTube thumbnail image, 16:9.
Focal subject: {CHARACTER or OBJECT: description from the visual bible, verbatim}, {pose and expression}, large in the frame, {left, right or center}.
Background: {simple background that supports the idea, with depth}.
Composition: strong subject, simple shapes, clear negative space {where the overlay text will go}.
Colors and lighting: {high contrast, 2 or 3 main colors from the style palette}, {lighting}.
{FILM_LINE}
{STYLE_BLOCK}
No text, letters or logos in the image.
Avoid: {NEGATIVE}
Aspect ratio: 16:9, at least 1280x720
```

Overlay text (added separately): "{TEXT}", bold sans-serif, white with dark outline, {position}, at most 4 words.

If the user wants the text in the image, change the last lines to include the exact text in quotes and warn that the result may be misspelled.

File names: `thumbnail_<NN>_<label>`, lowercase, hyphens in the label, for example `thumbnail_01_big-question.png`.

Extract candidate frames from the final video with ffmpeg:

```
ffmpeg -ss 00:01:30 -i render/final/<slug>_final.mp4 -frames:v 1 publish/thumbnail/frame_0130.png
```

Add overlay text to a finished image (needs ffmpeg with drawtext and a font file; adjust the font path for the system):

```
ffmpeg -i thumbnail_01_big-question.png -vf "drawtext=fontfile=/path/to/font.ttf:text='WHY?':fontsize=160:fontcolor=white:borderw=8:bordercolor=black:x=60:y=h-th-60" thumbnail_01_big-question_text.png
```

Check size: `ffprobe -v error -show_entries stream=width,height -of csv=p=0 FILE`. If a file is over 2 MB, re-save it as JPG with ffmpeg (`-q:v 3`).

## AI content disclosure

YouTube asks creators to disclose realistic content that was made or changed with AI (for example realistic people, places or events that did not happen) in the upload form. Clearly stylized, animated or fantasy content is usually outside that rule. Policies change and are the creator's responsibility. Remind the user to read the current YouTube policy and answer the disclosure question in the upload form themselves.

## Channel profile (saved in the config)

```json
"channel": {
  "name": "Channel name",
  "niche": "science explainers",
  "title_style": "question or curiosity, under 60 characters",
  "cta": "Subscribe for a new video every week.",
  "links": ["https://example.com"],
  "default_tags": ["science", "explained"],
  "description_footer": "Business inquiries: ..."
}
```

Never store passwords or tokens.

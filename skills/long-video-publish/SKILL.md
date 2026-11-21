---
name: long-video-publish
description: Prepare the YouTube packaging for the finished video: title options, a full description with chapters and credits, tags and hashtags, and thumbnail concepts with image prompts (made or handed over like the earlier image stages). Checks the text against YouTube limits and saves everything for the user to paste in. Use after long-video-render has produced the final video, or when the user asks for a YouTube title, description, tags, chapters or thumbnail.
---

# Long video publish

Stage 10 of the long video workflow. Output: a title, a description, tags and a thumbnail prompt (or the finished thumbnail) for YouTube, saved in `publish/`.

This stage prepares text and images. It does not upload or publish anything.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. The best moment is after `long-video-render` finished (`final_video` in `project.json`). It also works with only an approved story and script, with a note that chapters are estimates until the video is final.
2. Load: `story.md`, `video-script.md`, `film-style.md`, `visual-bible.md`, `sound/credits.md` if it exists, and the config (language, audience, tone, platform, image provider).
3. Get the final video length with `ffprobe` if the file exists. Otherwise use the script's total runtime.
4. If `publish/` already exists, ask: continue, or restart one part.

## Step 1: Ask what the config does not know

Ask only what is missing, in one short group. Use defaults when the user says "you pick".

- **Channel.** Name, niche, usual style of titles, and an existing signature or call to action. If the config has a `channel` profile, show it and ask "Anything to change?".
- **Metadata language.** Default: the video's language.
- **Must-include.** Keywords, names, links (website, social, a series playlist).
- **Avoid.** Words or claims to avoid.
- **Goal.** More searches, more suggested views, or a loyal audience. This steers the title style.

Offer to save the answers as the `channel` profile in the config for next time.

## Step 2: Research (optional)

If a keyword or title research tool is connected (for example a YouTube research MCP server), offer to use it. Tell the user it may use credits. Use it for: keyword ideas, how competing titles look, title scores. Without a tool, work from the story and say that no search data was used. Never invent search volumes, view counts or rankings.

## Step 3: Titles

Read `references/youtube-metadata.md`.

1. Write 10 title options for the video. Cover different angles (curiosity, question, benefit, number, contrast, story). Each title:
   - is 60 characters or fewer when possible, 100 at most,
   - puts the main keyword near the front,
   - is truthful: the video must deliver what the title promises,
   - fits the language, tone and audience.
2. Show them numbered, each with the angle and a one-line reason. Recommend your top 3.
3. Ask the user to pick one, combine two, edit one, or ask for more. For more, write 10 new titles that were not shown before, with different angles. Repeat until the user agrees on one title.
4. Keep 2 runner-up titles for the description of alternatives (useful for title tests).

## Step 4: Thumbnail

1. Write 3 thumbnail concepts. Each has: the subject and pose, the background, the colors, 0 to 4 words of overlay text, and the idea it sells. Follow the principles in the reference (one clear focal point, high contrast, readable at small size, matches the title without repeating it).
2. Ask the user to pick one or more. Three distinct concepts can be used for a thumbnail test on YouTube if the channel has that feature.
3. For each chosen concept write one image prompt. Use the locked art style block, the film style line and the entity descriptions from `visual-bible.md` verbatim, and list the reference images to attach (the character image and sheet). Format and size rules are in the reference. Put the overlay text outside the image prompt by default, because image generators often garble text. Say so, and give the text, font suggestion and position for adding it later. If the user wants the text inside the image, include it and warn.
4. A frame from the video can serve as the base. Offer to extract candidate frames from the final video with ffmpeg.
5. Name the files: `publish/thumbnail/thumbnail_<NN>_<label>.png`. The prompt header holds the file name, like the earlier image stages.
6. Ask: **prompts only, images, or both** (as in `long-video-assets`).
   - **Prompts only.** Create `publish/thumbnail/`, show the full path, and tell the user to save the images there with those names.
   - **Images or both.** Read `../long-video-assets/references/image-generation.md` and follow it (method discovery, browser rules, retries, status). Generate at 16:9 and check the size: 1280x720 or larger, under 2 MB, JPG or PNG. Convert or compress with ffmpeg if needed.
7. Offer to add the overlay text with ffmpeg on request.

## Step 5: Description

Write the description with this structure (details in the reference):

1. First two lines: the hook and the main keyword. They show before "show more".
2. A short summary of the video (2 to 4 sentences, natural language).
3. Chapters: timestamps built from the script's scenes and the final timeline. The first is `0:00`. At least 3, each at least 10 seconds long. Use clear short names.
4. Links and the call to action from the channel profile.
5. Sources, for a non-fiction video: the items from the story's "facts to verify" that were confirmed. Do not list sources that were not checked.
6. Credits: copy the lines from `sound/credits.md` exactly. Licences such as CC BY require them.
7. Up to 3 hashtags at the end.
8. A disclosure reminder if the video has realistic AI-generated or altered content (see the reference). Tell the user to check the upload form.

## Step 6: Tags

Write 10 to 15 tags: the main keyword first, then close variants, topic words and a few broader terms. Total length at most 500 characters including commas. Tags matter little for ranking, so do not stuff them.

## Step 7: Check, review, save

1. Write `publish/metadata.json` with `title`, `description` and `tags`. Run:

```
node <skill folder>/scripts/check-metadata.mjs publish/metadata.json --duration <video seconds>
```

   Fix every error. Consider every warning.

2. Show the user the title, the description, the tags and the thumbnail concept in one short summary. Ask for changes. Apply them, run the check again, and repeat until the user explicitly approves.
3. Save:
   - `publish/metadata.md`: title, runner-up titles, description, tags, hashtags, chapters, thumbnail text. Ready to copy.
   - `publish/metadata.json`: the same, machine readable.
   - `publish/thumbnail-prompts.md`: the thumbnail prompts with file names.
4. Update `project.json`: `"stage": "publish-ready"` and the paths.
5. Tell the user the paths and that the final video is at `render/final/`. Say that they upload it, or ask Claude to help with an upload tool if one exists. Do not upload without a clear request. If asked, confirm the title, privacy setting (suggest private or unlisted first) and the file before sending.
6. Offer to save the channel profile in the config.
7. Stop. Do not start any later stage unless the user asks and that stage exists.

## Rules

- Never claim the title or thumbnail will perform. Say what the choices are based on.
- Never write a title or thumbnail that promises what the video does not show.
- Never list sources that were not verified. Never invent facts, statistics or quotes.
- Never skip the credits for licensed sounds.
- Never publish or upload without the user's explicit request.
- Never use a real person's name or likeness, or a trademark, in a thumbnail prompt.
- Keep chat messages short. Put the full text in `publish/`.

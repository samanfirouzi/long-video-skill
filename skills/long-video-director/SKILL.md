---
name: long-video-director
description: Turn an approved story into a shot-by-shot video script, acting as the director. Asks whether the video uses a narrator or characters who speak (or both), suggests professional filming choices (camera type, lenses, camera movement, lighting, color, pacing), saves them as a separate film style file, then writes a script that matches the project config. Outputs film-style.md and video-script.md. Use after long-video-story (and long-video-assets) are done, or when the user asks for the video script, shot list, camera style or lighting plan.
---

# Long video director

Stage 4 of the long video workflow. You are the director. Output: `film-style.md` and `video-script.md` in the project folder.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. Require `story.md` with `status: approved`. If not approved, stop and run `long-video-story`.
2. Require `visual-bible.md` (entity ids and the locked art style). If it is missing, tell the user the art style is needed first and offer to run `long-video-assets`. Continue only if the user chooses to skip it. In that case ask for a short art style description and note it as "unlocked" in the film style.
3. Load the project config. Take from it: language, target length, aspect ratio, audience, tone, visual approach, voiceover source and provider, captions, music, budget. Do not re-ask what the config answers.
4. If `film-style.md` or `video-script.md` already exists, ask: continue, or restart one of them.

## Step 1: Narration or characters speaking

Ask: "How should the video speak?"

- **Narrator.** One voice tells the story over the pictures.
- **Characters speak.** The characters talk to each other on screen. No narrator, or only a few title lines.
- **Mixed.** A narrator carries the story and characters speak in key scenes.

Before the user answers, give one line on what each choice means for production. Use the config's `visuals.approach` and `audio.voiceover`:

- Characters speaking needs one distinct voice per character. Still images or simple animation cannot show real lip-sync, so say which of these applies: lip-sync tool needed, off-screen delivery (the speaker is not shown while talking), or a style that hides mouths.
- A narrator is cheapest and works with every visual approach.

Recommend one option based on the story and the config. If the choice conflicts with the config (for example, `voiceover.source` is `none`), point it out and ask whether to update the config.

If characters speak, ask for a voice description for each character from the visual bible (age, tone, accent). Use the config's TTS provider if there is one.

## Step 2: Film style, as the director

Read `references/cinematography-options.md`. Walk the user through the groups below, one group at a time. For each group, suggest 3 to 4 options that suit this story. Give each a one-line reason. Mark the one you recommend. The user can pick, combine, or describe their own.

1. **Camera and format look**
2. **Lenses and framing**
3. **Camera movement**
4. **Lighting**
5. **Color and grade**
6. **Pacing and transitions**. Pacing works inside the clip limit: the average shot length must stay between 5 and 8 seconds unless the config says otherwise. Offer variety through shot size, movement and cut rhythm, not through long holds.

Rules:

- Everything must fit the locked art style and the config's visual approach. Do not suggest a physical cinema camera for a 2D illustrated style. For illustrated or still-image styles, offer the matching virtual camera moves instead (push-in, parallax, pan across the image) and say what the production can really do.
- Do not contradict the style block in `visual-bible.md`. The film style adds to it.
- Tie each suggestion to the story: mood, setting, era, genre.
- Use plain words. Explain a term the first time you use it.
- Ask for the user's choice for each group before moving on. If the user says "you decide", choose the recommended option and say what you chose.

## Step 3: Confirm and save the film style

1. Show the full film style as one summary: speaking mode, camera and format, lenses, movement, lighting, color, pacing, transitions, plus the art style block copied from the visual bible.
2. Ask the user to confirm or change items.
3. On an explicit yes, write `film-style.md` using `references/film-style-template.md`.
4. Offer to also save it as a reusable preset in `~/.long-video/film-styles/<preset-name>.md`. Use lowercase letters, digits and hyphens. If the user declines, skip.

The film style is now locked. Do not change it while writing the script without asking.

## Step 4: Write the script

Read `references/script-format.md` and follow its format and timing rules.

Rules:

- Match the config: language, target length, aspect ratio, audience, tone, captions, voiceover mode.
- Stay faithful to the approved story. Cover every beat. Do not add facts, events or claims that are not in the story. Where the story is narration text (for example from `long-video-story-questions`), keep that text word for word and add structure around it.
- Break the story into scenes, and each scene into shots. Every shot gets: duration, picture, camera (size, angle, movement), lighting, sound, transition.
- **Clip length limit.** Every shot (one picture or clip) lasts at most 10 seconds. Aim for 5 to 8 seconds. Read `video.max_clip_seconds` and `video.preferred_clip_seconds` from the config if set. Defaults: max 10, preferred 5 to 8. Shots shorter than 5 seconds are allowed only for a reason (a quick insert, a beat of impact). Never exceed the maximum. If a moment needs more time than the limit allows, split it into consecutive clips (shots) at a sentence, clause or action boundary. The clips may share the same environment, camera and lighting, and the picture may stay the same or continue the same action. The final result is longer than any single clip. Mark each follow-on clip with `Continues: <previous shot id>`, and keep the narration or dialogue word for word. Do not invent new camera moves or new pictures just to fill the extra clips.
- Apply the film style to every shot. Vary shot size and movement for rhythm, within the locked style.
- Use entity ids from the visual bible for every character, environment and object. If a shot needs something not in the bible, list it under "New assets needed" instead of silently inventing it.
- Narration: write the text in the config's language. Dialogue: write `CHARACTER: line` with a delivery note in parentheses where it matters. Keep each line speakable in one breath.
- Add up the runtime. It must land within 10 percent of the target length. If it does not, adjust before showing it.

## Step 5: Review

1. Show a summary table: scene number, title, runtime, shot count, speaking mode. Show the total runtime against the target.
2. Show the first scene in full. Offer other scenes on request.
3. List any "New assets needed".
4. Ask the user to approve or request changes.
5. Apply changes. Keep the film style unless the user asks to change it. If the film style changes, update `film-style.md` and recheck every shot.
6. Repeat until the user explicitly approves. Silence or "looks fine so far" is not approval. If unclear, ask: "Lock this script?"

Before showing the script, run this self-check and fix any failure:

- Total runtime is within 10 percent of target.
- Every story beat appears in the script.
- Every shot has duration, camera, lighting and sound.
- No shot is longer than the clip limit (10 seconds by default). Most shots fall in the preferred range (5 to 8 seconds). Report the count of shots outside it.
- Every entity id exists in the visual bible, or is listed under new assets.
- Language matches the config.
- No shot uses a camera move or lighting the film style excludes.

## Step 6: Save

1. Write `video-script.md` with the header from the format reference, status `approved` and the approval date.
2. Make sure `film-style.md` is saved.
3. Update `project.json`: `"stage": "script-approved"`, `"film_style": "film-style.md"`, `"script": "video-script.md"`.
4. Tell the user both file paths and the total runtime. If there are new assets needed, say so and offer to run `long-video-assets` for them.
5. Offer to continue with `long-video-keyframes` (start and end frame images for every scene). Start it only if the user agrees. Do not start any other later stage unless the user asks and that stage exists.

## Rules

- Never write the script before the film style is confirmed.
- Never approve the script without an explicit yes.
- Never change the story. If the story has a problem, tell the user and offer to reopen `long-video-story`.
- Never suggest a style that production cannot deliver with the user's visual approach.
- Keep chat messages short. Put the full text in the files.

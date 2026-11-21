---
name: long-video-voice
description: Create the spoken audio (narration and character voices) for the approved video script. First decides whether the video needs speech and asks the user to confirm. If yes, builds a voice cast (narrator plus each speaking character), makes a short sample of each voice with an available tool such as an ElevenLabs MCP and asks the user to approve the voices, then generates one audio file per spoken line with a name that holds the scene number and speaker. Or gives the user the lines, file names and folder to record or generate themselves. Use after long-video-clips (or long-video-keyframes), or when the user asks for narration, voiceover, voices or dialogue audio.
---

# Long video voice

Stage 7 of the long video workflow. Output: a folder of audio files, one per spoken line, each named by scene and speaker. Or a decision that the video needs no speech.

A **scene** means one clip of the script (one shot, 10 seconds at most), numbered in order across the video, as in the earlier stages.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. Require `video-script.md` with `status: approved` and `film-style.md`.
2. Load the project config: language, voiceover source and provider (`audio.voiceover`), `providers.tts`, approval level, budget.
3. Read the speaking mode and voice descriptions from `film-style.md`.
4. If `audio/` or `voice-scripts/` already exist, ask: continue (list what is done), or restart.

## Step 1: Does the video need speech?

Work it out before you ask. Check:

- the speaking mode in `film-style.md` (narrator, characters, mixed),
- `audio.voiceover.source` in the config (`none`, `self-recorded`, `cloud-tts`, `local-tts`),
- how many narration or dialogue lines the script contains, and in how many scenes.

Then give a recommendation with a reason, and ask for confirmation. Example: "The script has 142 narration lines in 96 of 104 scenes, and the config uses cloud text-to-speech. I recommend a narrated video. Do you want me to create the voices?"

- If the script has no spoken lines, or the config says no voiceover: recommend skipping, with the reason.
- **Approved.** Continue with Step 2.
- **Not needed.** Set `"voice_mode": "none"` and `"stage": "voice-skipped"` in `project.json`. Say the later stages will use music and effects only. Stop.
- **Disagrees with the recommendation.** Follow the user. Update the config note if speech was `none` and the user now wants it.

Never create any voice without the user's confirmation.

## Step 2: Build the voice cast

1. List every speaker: the narrator (if any) and each character that has dialogue. Count the lines for each.
2. For each speaker, take the voice description from `film-style.md` (age, tone, accent, speed). If a description is missing, propose one from the character description in `visual-bible.md` and mark it "proposed".
3. Show the cast as a table: speaker, id, number of lines, voice description. Ask the user to confirm or edit.
4. Speaker ids: `narrator`, or the character id without the `char-` prefix (for example `char-mara` becomes `mara`). These ids go into file names.

## Step 3: Choose how the audio is made

Ask: "Should Claude generate the voices, or will you make them yourself (record or use your own tool)?"

- **Claude generates.** Go to Step 4.
- **I make them.** Go to Step 6.
- **Both.** Write the voice scripts (Step 6) and also generate (Step 4).
- If `audio.voiceover.source` is `self-recorded`, go to Step 6 directly.

## Step 4: Find a voice tool and make samples

Read `references/voice-generation.md`. In short:

1. Use the method saved in the config (`providers.tts`) if there is one. Test it.
2. Look for connected tools in this session that generate speech (an ElevenLabs MCP or similar, or skills with speech tools).
3. Check API key environment variables on the device. Print only "set" or "not set".
4. Check local text-to-speech tools.
5. If nothing is found, ask whether the user has an API key (as an environment variable, never pasted in chat), an MCP server to connect, or a speech site in the browser. Or go to Step 6.

**Voice samples come first. Never generate the full audio before the user approves the voices.**

1. For every speaker, pick a voice that fits the description. List the tool's voices and choose from them. Never use a voice id from memory. If the tool can design a new voice from a description, offer that for hard-to-match voices.
2. Make one short sample per speaker (5 to 15 seconds). Use a real line from the script that speaker says, in the config language. For the narrator, use the opening lines. Include the delivery note if the line has one.
3. Save samples to `audio/samples/` as `sample_<speaker>.mp3`.
4. Present each sample with the speaker, the voice name, and the line. Ask the user to approve it, or ask for another voice. If they ask for another voice, make a new sample (one at a time, never batch retries). Repeat until each speaker is approved.
5. Record the approved voices in `voice-cast.md` (speaker, voice name, voice id, settings, sample file). Update the voice list in `film-style.md` to match.

Do not repeat a generation call to retry. Each call can charge again.

## Step 5: Generate the lines

1. Read `references/voice-script-format.md`. Build the line list from the script: one item per spoken line, in scene order.
2. Tell the user the number of lines, the total spoken time, and the rough cost. Ask before starting. Offer to start with a range, for example scenes 1 to 10.
3. **Test scene.** Generate the first scene with speech. Play it back or report its duration. Ask whether the delivery is right. Fix the settings first.
4. Generate in scene order using the approved voices only. Apply the delivery notes. Use the pronunciation notes from the line list.
5. Save each line as `audio/lines/scene-<NNN>_<speaker>_<NN>.<ext>`. Never overwrite a file without asking.
6. After each file, measure its duration with `ffprobe`. Compare it with the scene's duration in the script (see the format reference for the fit rules). Record the result.
7. If a line does not fit its scene, do not change the words. Offer options: a slightly faster delivery (at most 10 percent), a longer scene (still within the 10 second limit), or splitting the line across two scenes with the user's approval.
8. All at once or one by one: ask the user. One by one plays each line's result, waits for approval or a redo request.
9. If the tool makes its own audio inside the video clips (lip-sync), ask whether to keep that audio or use these files. Note the answer in `audio/status.md`.

If generation fails or the user declines, fall back to Step 6 for the remaining scenes.

## Step 6: Voice scripts for the user

1. Create `audio/lines/` for the finished audio files and `voice-scripts/` for the line lists. Show the full paths.
2. Write batch files of 20 scenes (`scenes-001-020.md`) and `voice-scripts/index.md`, following the format reference. Each line has:
   - the file name to save: `audio/lines/scene-007_narrator_01.mp3`
   - the speaker and the voice description
   - the exact text, the delivery note, and pronunciation notes
   - the scene duration, so the audio can be checked against it
3. Ask: **all at once, or one by one**.
   - **All at once.** Show the folder paths and one example. The user works through the batch files.
   - **One by one.** Show the first line with its file name. Wait for the user to say it is saved. Check that the file exists with the right name and measure its duration. Then show the next line.
4. Offer to check the folder at any time: compare files against the index, and list missing, misnamed or too-long audio.

## Step 7: Status and finish

1. Keep `audio/status.md` current with the table in the format reference. Status values: `pending`, `done`, `needs-manual`, `skipped`.
2. Update `project.json`: `"stage": "voice-prompts-done"` after the line lists are saved, and `"stage": "voice-done"` when every spoken line has an audio file and the user approves the set.
3. Tell the user the paths of `audio/` and `voice-scripts/`, the total spoken time against the video time, and what is missing or too long.
4. Offer to save the working tool in the config (`providers.tts`), method and names only.
5. Offer to continue with `long-video-sound` (sound effects, ambience and background music). Start it only if the user agrees. Do not start any other later stage unless the user asks and that stage exists.

## Rules

- Never create voices without the user's confirmation in Step 1.
- Never generate full audio before the voice samples are approved.
- Never change the script words. If a line does not fit, ask first.
- Never use a voice id that did not come from the tool's own voice list or from the user.
- Never ask for API keys in chat. Never enter passwords or solve CAPTCHAs in a browser.
- Never repeat a generation call silently to retry. Each call can charge again.
- Never rename a file after the line list is approved.
- Keep chat messages short. Put full line lists in files.

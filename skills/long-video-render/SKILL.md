---
name: long-video-render
description: Assemble the finished video and run the review loop. Builds the edit from the clips (or images with camera moves), voice, sound stems and captions, renders a low quality review version with scene numbers and time burned in so a client can review it, collects and applies changes (re-rendering reviews as often as needed), and when the user approves, renders the high quality final video. Uses a video editor with a CLI or MCP (FilmCraft, EffectCraft or another) if one is available and the user wants it, otherwise the bundled ffmpeg renderer. Use after long-video-sound, or when the user asks to render, assemble, export, preview or finalize the video.
---

# Long video render

Stage 9 of the long video workflow. Output: review renders (low quality) until the user approves, then one high quality final video.

A **scene** means one clip of the script, numbered in order across the video, as in the earlier stages. Scene numbers are burned into the review video, so the reviewer can point at them.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. Require `video-script.md` with `status: approved`.
2. Load the project config: resolution, aspect ratio, captions mode (`visuals.captions`), loudness needs, platform.
3. Check ffmpeg and ffprobe (`ffmpeg -version`). The bundled renderer needs ffmpeg with libx264 and libass.
4. If `render/` already exists, ask: continue (list the versions), or restart.

## Step 1: Inventory

Check every scene and list what exists:

| Item | Where | Used as |
|------|-------|---------|
| Video clip | `clips/scene-<NNN>_clip.*` (or `_take2` and later, whichever the user approved) | The scene's picture |
| Images only | `frames/scene-<NNN>_start.*` | A still with a camera move from the script (push-in, pull-out, pan) |
| Voice | `audio/lines/scene-<NNN>_<speaker>_<NN>.*` | Narration and dialogue |
| Sound stems | `sound/mix/sfx_track.wav`, `amb_track.wav`, `music_track.wav` | Effects, ambience, music |

Report the gaps in a short table. A scene with no clip and no image is a blocker: list those scenes and offer to go back to `long-video-keyframes` or `long-video-clips`. Missing voice or sound is allowed only if the user chose to skip those stages. If a stage was skipped, do not ask for it again.

If the clips stage was skipped (`clips_mode: images-only`), every scene becomes a still with a camera move taken from the script shot.

## Step 2: Choose the assembly tool

1. Check for a video editor that Claude can drive: a connected editing MCP server in this session, or a CLI on the device (FilmCraft: `filmcraft-cli commands`; EffectCraft: `effectcraft-cli --help`). See `../long-video-sound/references/tools.md`, section 5.
2. If one is available, ask: use it (the user can open the project and adjust it), or use the bundled renderer. Default to the bundled renderer. If the user picks the editor, read its command list and docs first, work on a copy, ask before installing or building anything, and keep the same file names.
3. Say which tool will be used.

The rest of this skill describes the bundled renderer. With an editor, do the same steps through its commands and export the review and final files to the same folders and names.

## Step 3: Build the edit list

Read `references/edl-format.md`. Write `render/edl.json` from the project files:

- one entry per scene with its duration (from the script, or the real clip length when shorter or longer within the scene length), picture source, camera move for stills, and transition out,
- voice placements: the scene's start time plus a short offset (0.3 s by default), lines in order with small gaps,
- the sound stems,
- captions from the voice text (start and end from each voice file's duration), if the config wants captions,
- width, height and fps from the config. Default fps is 24. The default loudness target is -14 LUFS with true peak below -1.5 dBTP.

Rules:

- Use the exact scene durations from the approved script. Do not stretch or shorten the story to fit.
- A clip longer than its scene is trimmed from the end. A clip shorter than its scene holds its last frame. Report both.
- A voice line that runs past its scene end, or past the video end, is reported as a warning.
- Transitions: `cut` by default. `fade` (dip to black) only where the script says so. Cross-dissolves need an editor tool.
- Check the plan before rendering: `node <skill folder>/scripts/build-render.mjs render/edl.json review render/review --plan`.

Show a short summary: number of scenes, total runtime against the target, clips versus stills, warnings. Fix problems that can be fixed without changing the story. Ask the user about anything that cannot.

## Step 4: Render the review version

Review quality: low resolution (about 360p), high compression, scene number and time burned into the top-left corner, and captions if the config uses burned-in captions.

```
node <skill folder>/scripts/build-render.mjs render/edl.json review render/review --version 1
```

- Output: `render/review/<slug>_review_v1.mp4`, plus a `.report.json` with duration, size and loudness.
- Scene segments are cached. Later reviews re-render only changed scenes, so they are much faster.
- For videos longer than a few minutes, run the command in the background and wait for it to finish. Do not poll.
- If the captions mode is `srt`, an `.srt` file is written next to the video.

Check the report: actual duration against the planned one, loudness, streams. Then tell the user the full path and the size.

Say how to review: watch the file, note the scene number and time shown in the corner with each comment. Claude does not send or upload the file. The user shares it with the client. Offer to prepare an upload only if the user asks, and ask first.

## Step 5: Collect changes

Ask: "Any changes? If it is final, say so and I will render the high quality version."

The user may paste the client's feedback. Read `references/review-feedback.md`. For each comment:

1. Find the scene number or the time it refers to. If the comment is vague, ask one short question.
2. Classify it and choose the route:
   - **Edit-level** (trim, length, order, caption text, captions on or off, transition, levels of voice, music or effects): fix it here in `edl.json` or the stems' gain.
   - **Picture of a scene** (look, character, composition, motion): go back to `long-video-keyframes` or `long-video-clips` for those scenes. New files get the `_take2` style names. Then update the edit list.
   - **Voice line** (delivery, pronunciation, wording): `long-video-voice` for those lines. A wording change to the approved script needs the user's approval and a script revision.
   - **Sound** (effect, ambience, music): `long-video-sound` for those cues, then mix again.
   - **Story or structure** (add or remove scenes): `long-video-director`, then redo only the affected scenes downstream.
3. Write the list into `render/review-log.md` with the version, scene, request, route and status.
4. Show the user the plan in a short table. Ask for a yes before any regeneration that costs credits or time.
5. Apply the changes, then render the next review (`--version 2`, and so on). Keep every older review file.
6. Tell the user what changed, scene by scene, and the new file path.

Repeat until the user approves. Silence or "looks good so far" is not approval.

## Step 6: Render the final video

Only after the user says explicitly that a specific review version is final.

1. Confirm: "Render the final from review v<N>?" Check that the edit list matches that version, and that no change request is still open in the review log.
2. Final quality: the config's resolution, high quality H.264 (crf 18, slow preset), AAC 192k, two-pass loudness normalization to the target, no review labels. Captions are burned in only if the config says burned-in. Otherwise an `.srt` file is written.
3. Run it, in the background for long videos:

```
node <skill folder>/scripts/build-render.mjs render/edl.json final render/final
```

4. Verify with the report and `ffprobe`: duration matches the plan, resolution and fps are right, there is one video and one audio stream, loudness is near the target (within about 1 LU) and true peak is below -1 dBFS.
5. Optionally check for unexpected black frames and long silence: `ffmpeg -i FILE -vf blackdetect=d=0.5 -af silencedetect=noise=-50dB:d=3 -f null -`. Report the findings.
6. Update `project.json`: `"stage": "final-rendered"`, `"final_video": "<path>"`, and the review version approved.
7. Tell the user the full path, size and duration. Remind them of the credits in `sound/credits.md` for the video description.
8. Offer to continue with `long-video-publish` (YouTube title options, description, tags and thumbnail prompt). Start it only if the user agrees. Do not publish or upload. Do not start any other later stage unless the user asks and that stage exists.

## Rules

- Never render the final without an explicit approval of a specific review version.
- Never change the approved script. If feedback needs it, route it and ask.
- Never send, share or upload a video without the user's clear request.
- Never delete older review renders.
- Never regenerate images, clips, voice or sound without the user's yes on the plan.
- Keep chat messages short. Put the change list in `render/review-log.md`.

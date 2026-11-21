---
name: long-video-keyframes
description: Create the start and end frame image for every scene (clip) of the approved video script. Writes one image prompt per frame with a fixed file name that holds the scene number and start or end, makes a folder for the images, and can generate the images with an available image tool, or hand the prompts to the user all at once or one by one. Use after long-video-director, or when the user asks for start frames, end frames, keyframes or scene images.
---

# Long video keyframes

Stage 5 of the long video workflow. Output: an image prompt for the start frame and the end frame of every scene, a `frames/` folder, and optionally the finished images.

In this stage a **scene** means one clip of the script (one shot, 10 seconds at most). Scenes are numbered in order across the whole video.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. Require `video-script.md` with `status: approved`. If not approved, stop and run `long-video-director`.
2. Require `film-style.md` and `visual-bible.md`. They hold the camera and lighting look and the locked art style.
3. Load the project config: aspect ratio, resolution, image provider, approval level, budget.
4. Check `images/` for the character, environment and object images from `long-video-assets`. They serve as references. If they are missing, say so. Continue only if the user agrees to write prompts without them.
5. If `frames/` or `frame-prompts/` already exist, ask: continue (list what is done), or restart.

## Step 1: Number the scenes

1. Read the script in order. Give every shot a scene number: 1, 2, 3, and so on, across the whole video. Pad to 3 digits (`scene-001`), or 4 digits if there are more than 999.
2. Build the map from scene number to script shot id (for example scene 7 is script shot 2.3).
3. Mark continuation clips (`Continues:` in the script). For these, the **start frame is the end frame of the previous scene**. Do not write a new start prompt. The index points to the previous end image.
4. Count the images: two per scene, minus the reused start frames. Tell the user the total.

## Step 2: Write the frame prompts

Read `references/frame-prompt-templates.md`. Write two prompts per scene (one for a continuation scene).

For each frame, work out from the script shot:

- **Start frame.** What the first frame of the clip shows: the first camera position, the characters' starting poses and positions, the lighting at that moment.
- **End frame.** What the last frame shows: where the camera moved to (for example tighter after a push-in), how the action ended, any change in light. It must be reachable from the start frame in the shot's duration. If the camera is static and nothing moves, the end frame is the same composition with a small natural change (a gesture, a light shift).
- Both frames show the same place, characters and objects, with the same camera setup unless the shot moves the camera.

Rules for every prompt:

1. **Self-contained.** No "same as above". Include everything the generator needs.
2. **Style block verbatim.** Copy the style block and negative terms from `visual-bible.md` exactly. Add the film style's "prompt line for generators". Add camera, lens and lighting from the shot.
3. **Entity descriptions verbatim.** Copy each character, environment and object description from the visual bible. Never paraphrase.
4. **References.** List the image files to attach: character image and sheet, environment image, objects. For an end frame, list the scene's own start frame as the first reference. Use the exact file names.
5. **Same framing.** Use the aspect ratio from the config in every prompt.
6. **No text in the picture.** No captions, subtitles, logos or signs with readable text, unless the story needs it.
7. No real person names, trademarks or living artist names.

Save the prompts in `frame-prompts/`, in batch files of 20 scenes: `scenes-001-020.md`, `scenes-021-040.md`, and so on. Also write `frame-prompts/index.md` (format in the templates).

## Step 3: File names and folders

Create `frames/` in the project folder. Never put images anywhere else.

File names are fixed and appear in the header of every prompt:

- `scene-<number>_start.png`
- `scene-<number>_end.png`

Examples: `scene-007_start.png`, `scene-007_end.png`. Any extension works (png, jpg, webp), but the base name must match. The name holds the scene number and the word start or end, so every frame can be found by name and sorts in order.

## Step 4: Ask what the user wants

Ask: "What do you want from this stage?"

- **Prompts only.** The user makes the images with their own tool.
- **Images.** Claude generates the images.
- **Both.** The user gets the prompts and Claude also generates the images.

The prompt files are always saved. This choice decides who makes the images.

Then ask how to deliver: **all at once, or one by one**.

### Prompts only

- **All at once.** Show the full path of `frames/` and of `frame-prompts/`. Show how the file names work, with one example. The user opens the batch files and works through them. Offer to check the folder later.
- **One by one.** Show the first prompt in chat with its file name and references to attach. Wait for the user to say it is saved. Check that the file exists in `frames/` with the right name. Then show the next prompt. If the user says "skip" or "stop", save the position in `frames/status.md` and stop.

Check the folder whenever the user asks, or at the end: compare the files found against the index and list what is missing or misnamed.

### Images or both

Read `../long-video-assets/references/image-generation.md` and follow its steps for finding a method, handling the browser option, ordering, checks and status. Use the method saved in the config if there is one. Changes for this stage:

- **Count and cost.** Tell the user how many images are needed and the rough time or cost. Ask before starting a large batch. Offer to start with a range, for example scenes 1 to 10.
- **Style test.** Generate `scene-001_start` first. Show it. Ask whether it matches the locked style and the character looks. Fix the prompts before going on.
- **Order.** For each scene: start frame, then end frame (the end frame uses the start frame as a reference when the method supports it). Then the next scene.
- **References.** Attach the character, environment and object images listed in the prompt. If the method accepts only one reference, use the most important one (the main character in the frame) and say so.
- **All at once or one by one.** All at once: generate the whole range, then show the results. One by one: show each pair, wait for approval or a redo request, then continue.
- **Browser option.** Same rules as in the assets stage: explicit confirmation of the count, time and download folder first. Never enter passwords or solve CAPTCHAs.
- **Checks.** After each image check the subject, the style match, the character look against the references, and the difference between the start and end frames. At most 2 retries, then mark `needs-manual`.
- **Never overwrite.** Never overwrite an existing frame without asking.

If generation fails or the user declines, fall back to the prompts-only path for the remaining scenes.

## Step 5: Status and finish

1. Keep `frames/status.md` current:

```
| Scene | Frame | File | Status | Note |
|-------|-------|------|--------|------|
| 001 | start | scene-001_start.png | done | |
| 001 | end | scene-001_end.png | pending | |
```

Status values: `pending`, `done`, `needs-manual`, `skipped`.

2. Update `project.json`: `"stage": "frames-prompts-done"` after the prompts are saved, and `"stage": "frames-images-done"` when every frame exists and the user approves the set.
3. Tell the user the paths of `frames/` and `frame-prompts/`, and what is still missing.
4. Offer to continue with `long-video-clips` (video clips from the frames, or skip it and use images only). Start it only if the user agrees. Do not start any other later stage unless the user asks and that stage exists.

## Self-check before saving the prompts

- Every scene has an end prompt. Every non-continuation scene has a start prompt.
- Every prompt has the file name in its header, matching the naming rule.
- Every prompt contains the style block, negative terms and film prompt line verbatim.
- Every character, environment and object in the shot appears with its description verbatim and its reference files listed.
- Start and end frames of a scene agree on place, characters and lighting, and differ in the way the shot says.
- The count of prompts matches the count promised to the user.

## Rules

- Never start without an approved script.
- Never generate images before the user chose "images" or "both".
- Never rename an image or a prompt file name after the prompts are approved.
- Never ask for API keys in chat.
- Keep chat messages short. Put full prompt text in files and show only samples or the current prompt.

---
name: long-video-clips
description: Turn the start and end frame images into video clips, one per scene. Asks whether the user wants AI video clips or will use only images (then the stage is skipped). If clips are wanted, finds an available video generator (MCP, API, local tool, or browser such as Higgsfield) or asks the user for one, and generates the clips; or hands the user a folder, a detailed professional prompt per scene, the clip file name, and the start and end image names to make the clips themselves. Use after long-video-keyframes, or when the user asks for video clips, image-to-video prompts or animated scenes.
---

# Long video clips

Stage 6 of the long video workflow. Output: a video clip for every scene, or a decision to use images only.

A **scene** means one clip of the script (one shot, 10 seconds at most), numbered in order across the video, as in `long-video-keyframes`.

## Before you start

1. Find the project in `~/.long-video/projects/<slug>/`. Require `video-script.md` with `status: approved` and `film-style.md`.
2. Look in `frames/` and `frame-prompts/index.md`. Start and end frame images are the inputs for the clips. If they are missing, say so and offer to run `long-video-keyframes`. A text-only clip without a start image is possible with some tools, but results are less consistent. Continue that way only if the user agrees.
3. Load the project config: aspect ratio, resolution, clip limits, video provider, approval level, budget.
4. If `clips/` or `clip-prompts/` already exist, ask: continue (list what is done), or restart.

## Step 1: Ask what the user wants

Ask: "Do you want AI video clips for the scenes, or will the video use only your images?"

- **Create video clips.** Continue with Step 2.
- **Images only.** Skip this stage. Set `"clips_mode": "images-only"` and `"stage": "clips-skipped"` in `project.json`. Tell the user the later assembly stage will animate the images with the camera moves from the script (push-in, pan, parallax). Offer the next stage if it exists. Stop.
- **Some scenes only.** Ask which scenes get clips (a list or ranges, or a rule such as "only action scenes"). The other scenes use images only. Save the list in `project.json` as `clips_scenes`.

## Step 2: Who makes the clips

Ask: "Should Claude generate the clips, or will you make them yourself?"

- **Claude generates.** Go to Step 3.
- **I make them.** Go to Step 5 (prompts for the user).
- **Both.** Write all the prompts (Step 5), and also generate with Claude (Step 3). The user can use whichever result they prefer.

## Step 3: Find a video generator

Read `references/video-generation.md`. In short:

1. Use the method saved in the config (`providers.video`) if there is one. Test it.
2. Look for connected tools in this session that generate video (MCP servers or skills), including Higgsfield, Runway, Kling, Veo, Luma, Pika, Sora or similar.
3. Check API key environment variables on the device. Print only "set" or "not set", never the value.
4. Check local generators and the GPU.
5. If nothing is found, tell the user and ask: do they have an API key (as an environment variable, never pasted in chat), an MCP server or skill to connect, or a video site they use in the browser (for example Higgsfield)? Or choose "I make them myself" and go to Step 5.

Record what the chosen tool can do, because it shapes the prompts:

- accepts a start image
- accepts an end image (first and last frame control)
- accepts reference images for characters
- clip lengths and the maximum
- resolutions and aspect ratios
- whether it makes its own audio or speech
- prompt length limit
- cost per clip

Tell the user the findings in a short list. If the tool cannot accept an end image, say so: the end frame prompt is then used only as a guide for the motion description.

## Step 4: Generate the clips

Follow `references/video-generation.md` for the order, the checks and the browser rules. Key points:

1. Write the prompts first (Step 5), because the generator needs them.
2. Tell the user the number of clips, the total seconds, and the rough cost or time. Ask before starting. Offer to start with a range, for example scenes 1 to 10.
3. **Test clip.** Generate `scene-001` alone. Show frames from it. Ask whether the motion, style and characters are right. Fix the prompts before going on.
4. Generate in scene order. For a continuation scene, use the real last frame of the previous clip as the start image if it drifted from the planned end frame (see the reference for the ffmpeg command).
5. After each clip check duration, resolution and look. At most 2 retries per scene, then mark `needs-manual`. Never repeat a generation call silently, because each call can cost credits.
6. Save each clip as `clips/scene-<number>_clip.<ext>`. Keep retakes as `scene-<number>_clip_take2.<ext>`. Never overwrite a file without asking.
7. Browser generation: get explicit confirmation of the count, time, site and download folder first. The user signs in. Never enter passwords or solve CAPTCHAs.
8. All at once or one by one: ask the user. One by one shows each clip's frames and waits for approval.

If generation fails or the user declines, fall back to Step 5 for the remaining scenes.

## Step 5: Prompts for the user

1. Create `clips/` for the finished videos and `clip-prompts/` for the prompts, in the project folder. Show the full paths.
2. Read `references/clip-prompt-templates.md`. Write one prompt per scene in batch files of 20 scenes (`scenes-001-020.md`), plus `clip-prompts/index.md`.
3. Every prompt has this in its header, so nothing gets lost:
   - the clip file name to save: `clips/scene-007_clip.mp4`
   - the start image: `frames/scene-007_start.png`
   - the end image: `frames/scene-007_end.png`
   - the duration, aspect ratio and resolution
4. Ask: **all at once, or one by one**.
   - **All at once.** Show the folder paths and one example prompt. The user works through the batch files.
   - **One by one.** Show the first prompt with its file name, start image and end image. Wait for the user to say the clip is saved. Check the file exists in `clips/` with the right name (and check duration with `ffprobe`). Then show the next prompt. If the user says "stop", save the position in `clips/status.md`.
5. Offer to check the folder at any time: compare files against the index, and list missing, misnamed or wrong-length clips.

## Prompt quality

Prompts must be professional and detailed. Each one covers:

- camera: shot size, angle, lens, movement with direction, speed and where it ends
- action: what the subjects do, beat by beat, across the clip's seconds
- lighting: type, direction, color, any change during the clip
- style: the locked art style block and the film style line
- what must not change: character look, setting, palette
- negative terms, duration, aspect ratio

Follow the template. Do not shorten the prompt to a few words.

## Step 6: Status and finish

1. Keep `clips/status.md` current:

```
| Scene | File | Status | Duration | Note |
|-------|------|--------|----------|------|
| 001 | scene-001_clip.mp4 | done | 6.0 s | |
| 002 | scene-002_clip.mp4 | needs-manual | | drifted twice |
```

Status values: `pending`, `done`, `needs-manual`, `skipped`.

2. Update `project.json`: `"stage": "clips-prompts-done"` after the prompts are saved, and `"stage": "clips-done"` when every wanted clip exists and the user approves the set.
3. Tell the user the paths of `clips/` and `clip-prompts/`, and what is missing.
4. Offer to save the working generator in the config (`providers.video`), method and names only.
5. Offer to continue with `long-video-voice` (narration and character voices). Start it only if the user agrees. Do not start any other later stage unless the user asks and that stage exists.

## Self-check before saving the prompts

- Every wanted scene has a prompt with the clip name, start image, end image, duration, aspect ratio and resolution in the header.
- Prompt duration matches the script and respects the tool's allowed lengths and the 10 second limit.
- Camera, lighting and style match `film-style.md` and the script shot.
- The style block and negative terms appear verbatim.
- If speaking mode is characters or mixed, the dialogue handling is stated in the prompt (see the template).
- The clip file names follow the rule exactly.

## Rules

- Never start without an approved script.
- Never skip Step 1. If the user wants images only, skip the stage and say so.
- Never generate before the user agreed to the count and cost.
- Never ask for API keys in chat. Never enter passwords or solve CAPTCHAs in a browser.
- Never rename a prompt file name or a clip name after the prompts are approved.
- Keep chat messages short. Put full prompt text in files and show only samples or the current prompt.

---
name: long-video-setup
description: Start a new long video project. Checks that required tools are installed, runs a Q&A about the user's video workflow, and saves or reloads a named config. Use when the user wants to make a long video, start a video project, or says "long video", "zero to hero video", or asks to load or edit a saved video config. Always run this before long-video-story.
---

# Long video setup

Stage 1 of the long video workflow. Output: a verified environment, a named config, and a project folder.

Hand over to `long-video-story` when done.

## Paths

- Configs: `~/.long-video/configs/<config-name>.json`
- Projects: `~/.long-video/projects/<project-slug>/project.json`

On Windows `~` is the user profile folder. Create folders if missing.

## Step 1: Check requirements

Run before any question. Read `references/requirements.md` for the full list and commands.

1. Run each check command. Record pass or fail.
2. Show a short result list: tool, status, version.
3. If a required tool fails: tell the user exactly what is missing and offer to install it for them. Use the system package manager from `references/requirements.md` (winget on Windows, Homebrew on macOS, apt, dnf, pacman or zypper on Linux). Show the exact command and wait for a clear yes before running it. The user types any password themselves. After installing, check again (a new terminal may be needed on Windows before the tool is visible). If the user declines or the install fails, give the manual install link and offer to re-check later. Do not continue to Q&A until all required tools pass.
4. If an optional tool fails: note it, continue. It matters only if the user picks a workflow that needs it. Re-check then.

Never install software without asking first.

## Step 2: Load or create a config

1. List files in `~/.long-video/configs/`.
2. If configs exist, ask the user: reuse one, reuse one and edit, or start fresh. Show config names with a one-line summary each (format, length, style).
3. If reusing: print the loaded values. Ask "Anything to change?". Re-ask only the changed questions. Skip to Step 4.
4. If none exist or starting fresh: go to Step 3.

## Step 3: Q&A

Read `references/questions.md`. Ask the questions in the groups listed there.

Rules:

- Ask one group at a time. Use `AskUserQuestion` when it is available, with at most 4 questions per call. Put the recommended option first.
- Offer a sensible default for every question. The user can answer "default" or "you pick".
- If an answer changes later questions (for example: voice is "I record myself", so skip TTS questions), skip those.
- If an answer reveals a missing requirement (for example: user picks an image provider needing an API key), run that check now, using `references/requirements.md`.
- Never ask for API key values in chat. Ask only which environment variable holds the key, and check that the variable is set.
- Do not ask about the story here. That is stage 2.

## Step 4: Confirm and save

1. Show the full config as a readable summary. Ask the user to confirm or change items.
2. Ask for a config name. Suggest one, for example `youtube-explainer-en`. Use lowercase letters, digits and hyphens only.
3. If the name exists, ask: overwrite or choose another name.
4. Write the JSON file. Schema in `references/config-schema.md`.
5. Tell the user the file path and that next time the config loads by name.

## Step 5: Create the project

1. Ask for a working title for this video. Make a slug from it.
2. Create `~/.long-video/projects/<slug>/project.json`:

```json
{
  "title": "<working title>",
  "slug": "<slug>",
  "config": "<config-name>",
  "stage": "setup-done",
  "created": "<ISO date>"
}
```

3. Tell the user setup is done. Start `long-video-story` for this project.

## Rules

- Never skip Step 1.
- Never write a config the user has not confirmed.
- Keep questions short. One topic per question.
- If the user asks to edit a config only (no new video), do Steps 2 to 4 and stop.

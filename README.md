# long-video

**Make a long YouTube video from zero, by talking to your AI coding tool.**

[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-12-brightgreen.svg)](skills)
[![Platforms](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](#install)
[![Status](https://img.shields.io/badge/status-early%20release-orange.svg)](#status)

`long-video` is a set of [agent skills](https://agentskills.io) that turn an AI coding tool (Claude Code, Codex, Gemini CLI, Cursor and more) into a video production assistant. You say "make a long video". The AI then walks you through every stage, from the idea to a finished video with a YouTube title and thumbnail, and asks for your approval before it moves on.

You do not need to be technical. You answer questions, approve or change what you are shown, and the AI does the work or gives you exact prompts and file names for the parts you want to do yourself.

## What it does

| # | Stage | You get |
|---|-------|---------|
| 1 | **Setup** | A check of the tools you need, a short Q&A about your workflow, and a saved named config you can reuse |
| 2 | **Story** | A story you approve. Bring your own, or let the AI write one in a style you pick (niche discovery, questions that challenge viewers, or open) |
| 3 | **Assets** | A list of the characters, places and objects that must stay the same, one art style you choose from suggestions, and image prompts (or the images) for all of them |
| 4 | **Director** | A shot-by-shot video script. You pick narrator or characters speaking, and the camera, lighting and pacing. Every shot is 10 seconds or less (5 to 8 preferred) |
| 5 | **Keyframes** | A start image and an end image for every scene, with fixed names like `scene-007_start.png` |
| 6 | **Clips** | Video clips for every scene from the keyframes, made by your video AI, or detailed prompts if you want to make them yourself. You can skip this and use only images |
| 7 | **Voice** | Narration and character voices. You approve a sample of each voice first. Files are named like `scene-007_narrator_01.mp3` |
| 8 | **Sound** | Sound effects, ambience and background music, with licences and credits tracked, mixed with the music lowered under speech |
| 9 | **Render** | A low quality review video with scene numbers burned in, for your client. You send changes, it fixes them, and renders the high quality final only when you approve |
| 10 | **Publish** | YouTube titles (10 options), a description with chapters and credits, tags, and thumbnail prompts |

```mermaid
flowchart LR
  A[1 Setup] --> B[2 Story] --> C[3 Assets] --> D[4 Director] --> E[5 Keyframes]
  E --> F[6 Clips] --> G[7 Voice] --> H[8 Sound] --> I[9 Render] --> J[10 Publish]
```

### How it works with your AI tools

- **Every stage asks first.** Nothing moves on until you say yes. The story, the art style, the voices, the script and the final render each need your explicit approval.
- **Your choice at the image, clip and voice stages:** the AI can generate with a tool you have (an installed generator, an API key, an MCP server, or your browser), or it gives you a folder, exact file names and a ready prompt for each item, all at once or one by one.
- **Nothing is uploaded or published for you.** Paid steps are explained first. The AI never asks you to type a password or an API key into the chat.
- **Everything is saved in plain files** in one folder per video, so you can stop and continue another day.

## Requirements

- An AI coding tool that supports skills, such as [Claude Code](https://claude.com/claude-code), Codex, Gemini CLI, Cursor, GitHub Copilot, OpenCode or Windsurf
- [ffmpeg](https://ffmpeg.org/), [Node.js](https://nodejs.org/) 18 or newer, and [git](https://git-scm.com/)

The installer checks these and offers to install what is missing. Image, video, voice and music generators are your choice and are optional: you can make those files yourself.

## Install

Pick the way you like. They all give the same result.

### 1. One command (recommended)

**Windows** (open PowerShell):

```powershell
irm https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.ps1 | iex
```

**macOS and Linux** (open Terminal):

```bash
curl -fsSL https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.sh | bash
```

The installer:

1. **Finds your AI tools.** Claude Code, Codex, Gemini CLI, Cursor, GitHub Copilot, OpenCode, Windsurf, Cline, Roo Code, Kiro CLI, Amp, Goose, Qwen Code, Droid and Continue.
2. **Lets you choose.** Type numbers or names to pick some, `a` for all of them, or `m` to see every supported tool.
3. **Asks where to install.** Global (every project, recommended) or this project only.
4. **Checks ffmpeg, Node.js and git** and offers to install what is missing (winget on Windows, Homebrew on macOS, apt, dnf, pacman or zypper on Linux). It shows the exact command and waits for your yes. If your computer asks for a password, type it yourself.
5. **Copies the skills.** If an older version is installed, the old copy is saved to `~/.long-video/backups/`.

Then restart your AI tool and say: `make a long video`.

Nothing is installed without your yes. You can read the scripts first: [install.ps1](install.ps1), [install.sh](install.sh).

### 2. Ask your AI tool to install it

Give your AI tool the GitHub URL. Paste this to it:

```text
Install the long-video skills from https://github.com/samanfirouzi/long-video-skill by following INSTALL.md
```

The AI reads [INSTALL.md](INSTALL.md), asks which tools and where, and installs the way your tool supports.

### 3. Use your tool's own installer

| Tool | Command |
|------|---------|
| Claude Code | `/plugin marketplace add samanfirouzi/long-video-skill` then `/plugin install long-video@long-video` |
| Gemini CLI | `gemini skills install https://github.com/samanfirouzi/long-video-skill.git --path skills --consent` |
| Codex | Ask Codex: `Use $skill-installer to install all skills under skills/ from samanfirouzi/long-video-skill into ~/.agents/skills` |
| Many other tools | `npx skills add samanfirouzi/long-video-skill` (the open [skills](https://github.com/vercel-labs/skills) CLI) |

These copy the skills only. The first time you start, the setup skill checks ffmpeg, Node.js and git and offers to install what is missing.

### 4. By hand

Clone the repository and copy the folders in `skills/` to your tool's skills folder. For Claude Code that is `~/.claude/skills/` (every project) or `<project>/.claude/skills/` (one project).

```bash
git clone https://github.com/samanfirouzi/long-video-skill.git
cp -r long-video-skill/skills/* ~/.claude/skills/
```

### Installer options

Use these when you run the installer from a downloaded copy, or pass them to the one-line command as shown below.

| Option | Windows (`.\install.ps1`) | macOS and Linux (`./install.sh`) |
|--------|---------------------------|----------------------------------|
| Global or project | `-Scope global` or `-Scope project` | `--scope global` or `--scope project` |
| Project folder | `-Path C:\my\project` | `--path /my/project` |
| Which tools | `-Agents all` or `-Agents claude-code,codex` | `--agents all` or `--agents claude-code,codex` |
| List supported tools | `-ListAgents` | `--list-agents` |
| Answer yes to everything, including installing tools | `-Yes` | `--yes` |
| Only check the tools | `-CheckOnly` | `--check` |
| Remove the skills | `-Uninstall` | `--uninstall` |

With the one-line command:

```powershell
# Windows: options through environment variables
$env:LONG_VIDEO_SCOPE='project'; $env:LONG_VIDEO_AGENTS='claude-code,codex'
irm https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.ps1 | iex
```

```bash
# macOS and Linux: pass options after -s --
curl -fsSL https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.sh | bash -s -- --scope project --agents claude-code
```

### Update and uninstall

- **Update:** run the installer again. It replaces the skills and keeps a backup of the old ones.
- **Uninstall:** run the installer with `-Uninstall` (Windows) or `--uninstall` (macOS and Linux). Your videos and configs in `~/.long-video/` are kept.

### Troubleshooting

- **PowerShell says scripts are disabled.** The one-line command is not affected. If you saved `install.ps1` and run it as a file, use `powershell -ExecutionPolicy Bypass -File .\install.ps1`.
- **A tool was installed but is "not visible yet".** Close the terminal, open a new one, and run the installer again. The new tool is only found in a fresh window.
- **Your tool is not in the list.** Use `npx skills add samanfirouzi/long-video-skill`, which supports many more tools, or copy the folders by hand.
- **The AI does not react to "make a long video".** Restart the AI tool after installing so it loads the new skills.

## Example

A short, illustrative session. Your AI's exact wording will differ.

```text
You:     make a long video

Claude:  Checking what the skills need...
           ffmpeg       ok
           ffprobe      ok
           node         ok  v22
           git          ok
         No saved config yet. A few questions about your workflow.
         Which format fits best?  1) explainer  2) documentary  3) storytelling ...

You:     explainer, about 12 minutes, English, YouTube, 16:9

Claude:  ... (six short groups of questions: audience, visuals, voice, tools, working style)
         Here is your config. What should I call it?

You:     science-explainer

Claude:  Saved. Working title for this video?

You:     Why is the sea salty?

Claude:  Do you have a story, or should I write one?

You:     write one

Claude:  Which story style?
           1) open  - I pitch ideas and write a story
           2) niche - find a niche and topic with seven discovery lenses
           3) questions - narration that challenges an "obvious" answer
         ...
```

After the story is approved, the next stages follow the same pattern. The AI then asks, for example:

```text
Claude:  Characters and places that must look the same in every shot: ... Confirm or edit.
         Here are 10 art styles that fit this story. Pick one, combine two, or ask for 10 more.
         ...
         Do you want prompts, images, or both?
```

Later stages, in one line each:

- **Director:** "Should the video use a narrator, characters speaking, or both?", then suggested camera, lighting and pacing.
- **Voice:** it plays a short sample for each voice and asks "Is this the voice you want?"
- **Render:** "Here is the review video. Any changes? If it is final, say so and I will render the high quality version."
- **Publish:** ten title options and thumbnail concepts.

You can leave at any point and come back. Say `continue my long video` and the AI reads the project folder to see where you stopped.

## Where your files go

Saved settings and videos live in your home folder, in `~/.long-video/`.

```text
~/.long-video/
  configs/                 your saved workflow configs, one per name
  film-styles/             reusable camera and lighting styles
  backups/                 old skill copies saved by the installer
  projects/<video-name>/
    project.json           where you are in the workflow
    story.md               the approved story
    visual-bible.md        characters, places, objects and the locked art style
    prompts/  images/      image prompts and the finished images
    film-style.md          camera, lighting and pacing
    video-script.md        the shot-by-shot script
    frame-prompts/  frames/    start and end frame prompts and images
    clip-prompts/   clips/     video prompts and clips
    voice-scripts/  audio/     voice lines and audio files
    sound/                 sound plan, sources, cuts, cue sheet, stems, credits
    render/                edit list, review videos, review log, final video
    publish/               title, description, tags, thumbnail
```

Every file has a fixed name that holds the scene number, so nothing gets lost. For example `scene-007_start.png`, `scene-007_clip.mp4`, `scene-007_narrator_01.mp3`, `scene-007_sfx_01_door-close.wav`.

## The skills

| Skill | Stage |
|-------|-------|
| [`long-video-setup`](skills/long-video-setup/SKILL.md) | 1. Requirements check, Q&A, saved configs, project folder |
| [`long-video-story`](skills/long-video-story/SKILL.md) | 2. Story, with pluggable styles |
| [`long-video-niche-discovery`](skills/long-video-niche-discovery/SKILL.md) | 2a. Story style: niche and topic discovery |
| [`long-video-story-questions`](skills/long-video-story-questions/SKILL.md) | 2b. Story style: questions that challenge obvious answers |
| [`long-video-assets`](skills/long-video-assets/SKILL.md) | 3. Characters, places, objects, art style, image prompts |
| [`long-video-director`](skills/long-video-director/SKILL.md) | 4. Film style and shot-by-shot script |
| [`long-video-keyframes`](skills/long-video-keyframes/SKILL.md) | 5. Start and end frame for every scene |
| [`long-video-clips`](skills/long-video-clips/SKILL.md) | 6. Video clips (or skip) |
| [`long-video-voice`](skills/long-video-voice/SKILL.md) | 7. Narration and character voices |
| [`long-video-sound`](skills/long-video-sound/SKILL.md) | 8. Sound effects, ambience, music |
| [`long-video-render`](skills/long-video-render/SKILL.md) | 9. Review render, change loop, final render |
| [`long-video-publish`](skills/long-video-publish/SKILL.md) | 10. YouTube title, description, tags, thumbnail |

### Helper scripts

Small tools that need only Node.js 18+ and ffmpeg:

- [`mix-cues.mjs`](skills/long-video-sound/scripts/mix-cues.mjs): places sounds on a timeline and writes effects, ambience and music stems, with the music lowered under speech
- [`build-render.mjs`](skills/long-video-render/scripts/build-render.mjs): assembles the video and renders the review and final versions
- [`check-metadata.mjs`](skills/long-video-publish/scripts/check-metadata.mjs): checks a YouTube title, description and tags against the limits

### Optional outside tools

The stages can use these. None is required, and nothing is installed or paid for without asking.

- [Openverse](https://github.com/WordPress/openverse): openly licensed sound effects and music
- [Earshot](https://github.com/Leonxlnx/earshot): make sound effects from words and judge sounds
- [Clipwing skills](https://github.com/Clipwing/skills) (`real-sfx`): place real sounds on the picture
- [FilmCraft](https://github.com/storytold/filmcraft) and [EffectCraft](https://github.com/storytold/effectcraft): open-source video editing and motion graphics with a CLI and MCP server. Any other editing CLI or MCP can be used the same way
- Image, video and voice generators you already use, through an installed tool, an API key, an MCP server or your browser

## Status

Early release (`0.1.0`). The helper scripts and the installers are tested. The conversation flows of the skills are new and still being tried on real projects, so expect rough edges. The skills were written and tested with Claude Code. Other tools read the same files, but steps that use MCP servers or a browser depend on what that tool offers. [Open an issue](https://github.com/samanfirouzi/long-video-skill/issues) if something breaks.

## Contributing

Pull requests are welcome.

- Each skill is a folder under `skills/` with a `SKILL.md` (front matter with `name`, equal to the folder name, and `description`) and optional `references/` and `scripts/` folders.
- Add a new **story style** by creating a skill and adding a row to [`story-styles.md`](skills/long-video-story/references/story-styles.md).
- Keep the installers (`install.ps1`, `install.sh`) ASCII only, and keep this README and [INSTALL.md](INSTALL.md) in step with any change.
- AI tools working in this repository should read [AGENTS.md](AGENTS.md).

## License

[Apache License 2.0](LICENSE).

# long-video

Zero-to-hero long video generator, built as a set of Claude Code skills.

You describe what you want. The skills walk you through the workflow, one stage at a time, and ask you to confirm each stage before moving on.

## Status

Early work in progress. Stages implemented so far:

| Stage | Skill | What it does |
|-------|-------|--------------|
| 1 | `long-video-setup` | Checks requirements, runs a Q&A about your workflow, saves it as a named config |
| 2 | `long-video-story` | Takes your story, or writes one in a style you pick, then loops until you approve it |
| 2a | `long-video-niche-discovery` | Story style "niche": finds a differentiated niche and first topic with 7 discovery lenses, 10 candidates at a time |
| 2b | `long-video-story-questions` | Story style "questions": narration that challenges obvious answers and hands the question back to the viewer |

New story styles are plugged in through `skills/long-video-story/references/story-styles.md`.

| 3 | `long-video-assets` | Lists recurring characters, environments and objects from the story, helps you lock one art style (10 suggestions at a time), and writes image prompts that share that style. Then you choose: prompts only (you get an `images/` folder and exact file names), images (Claude generates them via a local tool, API, MCP or your browser), or both |

| 4 | `long-video-director` | Acts as the director: asks narrator or characters speaking, suggests camera type, lenses, movement, lighting, color and pacing, saves them as `film-style.md`, then writes a shot-by-shot `video-script.md` that matches your config |

| 5 | `long-video-keyframes` | Writes a start-frame and an end-frame image prompt for every scene (clip), with fixed names like `scene-007_start.png`. Prompts only (all at once or one by one) or Claude generates the images |

| 6 | `long-video-clips` | Asks whether you want AI video clips or images only (then it skips). If clips: finds a generator (MCP, API, local, browser such as Higgsfield) or asks for one, or gives you a folder and a detailed prompt per scene with the clip name, start image and end image |

| 7 | `long-video-voice` | Decides if the video needs speech and asks you to confirm. Builds a voice cast (narrator and each speaking character), makes a sample of each voice for your approval (for example with an ElevenLabs MCP), then generates one audio file per line named like `scene-007_narrator_01.mp3`, or gives you the lines and file names to make yourself |

| 8 | `long-video-sound` | Plans the sound design from the script, then sources or makes each sound with Openverse (openly licensed recordings and music), Earshot (makes sounds from words and listens to judge them) and Clipwing real-sfx (places sounds on exact frames). Records licences and credits, and mixes separate effects, ambience and music stems with the music ducked under speech |

| 9 | `long-video-render` | Assembles the video (clips or stills with camera moves, voice, sound stems, captions) and renders a low quality review version with scene number and time burned in. Collects the client's changes, routes each one to the right stage, re-renders reviews, and renders the high quality final only when you approve. Uses FilmCraft, EffectCraft or another editor CLI or MCP if available and wanted, otherwise bundled ffmpeg |

| 10 | `long-video-publish` | Offers 10 YouTube title options (more on request), a description with chapters, sources and the licence credits, tags and hashtags, and thumbnail concepts with image prompts (prompts only, generated, or both). Checks the text against YouTube limits. Does not upload |

### Optional outside tools

The sound stage can use these. None is required, and nothing is installed without asking.

- [Openverse](https://github.com/WordPress/openverse): search openly licensed sounds and music
- [Earshot](https://github.com/Leonxlnx/earshot): make and judge sound effects
- [Clipwing skills](https://github.com/Clipwing/skills) (`real-sfx`): place real sounds on the picture
- [FilmCraft](https://github.com/storytold/filmcraft) and [EffectCraft](https://github.com/storytold/effectcraft): open-source editor and motion-graphics tools with a CLI and MCP server. Any other editing CLI or MCP that is available can be used the same way

## Install

You need [Claude Code](https://claude.com/claude-code). Then run one command in a terminal. No technical knowledge needed: the installer asks simple questions.

**Windows** (open PowerShell):

```powershell
irm https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.ps1 | iex
```

**macOS and Linux** (open Terminal):

```bash
curl -fsSL https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.sh | bash
```

What the installer does:

1. **Finds your AI tools.** It looks for Claude Code, Codex, Gemini CLI, Cursor, GitHub Copilot, OpenCode, Windsurf, Cline, Roo Code, Kiro CLI, Amp, Goose, Qwen Code, Droid and Continue.
2. **Lets you choose.** Pick some of the tools it found by number or name, or type `a` for all of them. Type `m` to see every supported tool.
3. **Asks where to install.** Global (every project, recommended) or this project only. Tools that share a folder get one copy.
4. **Checks the tools the skills need.** ffmpeg, Node.js 18 or newer, and git.
5. **Offers to install what is missing.** It uses winget on Windows, Homebrew on macOS, and apt, dnf, pacman or zypper on Linux. It tells you the exact command first and waits for your yes. Your computer may ask for your password. Type it yourself.
6. **Copies the skills.** If an older version is installed, it saves the old copy to `~/.long-video/backups/` first.
7. **Tells you what to do next.** Restart your AI tool, then say "make a long video".

Nothing is installed without your yes. Read the script before you run it if you like: [install.ps1](install.ps1), [install.sh](install.sh).

### Options

Use these when you have downloaded the repository, or add them after the one-line command as shown.

| Option | Windows (`.\install.ps1`) | macOS and Linux (`./install.sh`) |
|--------|---------------------------|----------------------------------|
| Choose the scope without being asked | `-Scope global` or `-Scope project` | `--scope global` or `--scope project` |
| Project folder | `-Path C:\my\project` | `--path /my/project` |
| Choose the tools without being asked | `-Agents all` or `-Agents claude-code,codex` | `--agents all` or `--agents claude-code,codex` |
| List the supported tools and which were found | `-ListAgents` | `--list-agents` |
| Answer yes to everything, including installing tools | `-Yes` | `--yes` |
| Only check the tools | `-CheckOnly` | `--check` |
| Remove the skills | `-Uninstall` | `--uninstall` |

With the one-line command, set options through environment variables on Windows (`$env:LONG_VIDEO_SCOPE='project'`) or pass them to bash: `curl ... | bash -s -- --scope project`.

Uninstall keeps your videos and configs in `~/.long-video/`.

### Or ask your AI tool to install it

Give your AI coding tool the GitHub URL. Paste this to it:

```
Install the long-video skills from https://github.com/samanfirouzi/long-video-skill by following INSTALL.md
```

The AI reads [INSTALL.md](INSTALL.md), asks which tools and where, and installs it the way your tool supports.

### Or use your tool's own installer

| Tool | Command |
|------|---------|
| Claude Code | `/plugin marketplace add samanfirouzi/long-video-skill` then `/plugin install long-video@long-video` |
| Gemini CLI | `gemini skills install https://github.com/samanfirouzi/long-video-skill.git --path skills --consent` |
| Codex | Ask Codex: `Use $skill-installer to install all skills under skills/ from samanfirouzi/long-video-skill into ~/.agents/skills` |
| Many other tools | `npx skills add samanfirouzi/long-video-skill` (the open [skills](https://github.com/vercel-labs/skills) CLI) |

These copy the skills only. The first time you say "make a long video", the setup skill checks for ffmpeg, Node.js and git and offers to install what is missing.

### By hand

Copy the folders in `skills/` to your tool's skills folder (for Claude Code: `~/.claude/skills/` for every project, or `<project>/.claude/skills/` for one project).

### If PowerShell blocks the script

The one-line command is not affected. If you saved `install.ps1` and run it as a file and Windows refuses, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Tools some stages use later

The stages that make images, video, voice or music ask you before using any outside tool or service, and tell you the cost first. They never install anything without asking. See stages 3, 6, 7 and 8.

## Use

Say "make a long video" or "start a new long video project". The `long-video-setup` skill starts automatically.

### Saved configs

Answers from the Q&A are saved as a named config in `~/.long-video/configs/<name>.json`. On the next run the skill lists your saved configs and offers to reuse one, so you answer only what changed.

### Projects

Each video lives in its own folder, `~/.long-video/projects/<project-slug>/`, holding `project.json` (state), `story.md` (the approved story), `visual-bible.md` (entities and locked style) `prompts/` (image prompts), `images/` (finished images), `film-style.md` (camera, lighting, pacing), `video-script.md` (shot-by-shot script), `frame-prompts/` (start and end frame prompts) `frames/` (start and end frame images), `clip-prompts/` (video prompts) `clips/` (video clips), `voice-scripts/` (line lists), `voice-cast.md` (approved voices) `audio/` (voice samples and line audio) and `sound/` (sound design, sources, cut files, cue sheet, stems, credits) `render/` (edit list, review versions, review log, final video) and `publish/` (title, description, tags, thumbnail prompts and images). Later stages add their own files there.

## Layout

```
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
INSTALL.md
AGENTS.md
install.ps1
install.sh
skills/
  long-video-setup/
    SKILL.md
    references/requirements.md
    references/questions.md
    references/config-schema.md
  long-video-story/
    SKILL.md
    references/story-styles.md
  long-video-niche-discovery/
    SKILL.md
  long-video-story-questions/
    SKILL.md
  long-video-assets/
    SKILL.md
    references/style-catalog.md
    references/prompt-templates.md
    references/image-generation.md
  long-video-director/
    SKILL.md
    references/cinematography-options.md
    references/film-style-template.md
    references/script-format.md
  long-video-keyframes/
    SKILL.md
    references/frame-prompt-templates.md
  long-video-clips/
    SKILL.md
    references/video-generation.md
    references/clip-prompt-templates.md
  long-video-voice/
    SKILL.md
    references/voice-generation.md
    references/voice-script-format.md
  long-video-sound/
    SKILL.md
    scripts/mix-cues.mjs
    references/tools.md
    references/sound-design.md
  long-video-render/
    SKILL.md
    scripts/build-render.mjs
    references/edl-format.md
    references/review-feedback.md
  long-video-publish/
    SKILL.md
    scripts/check-metadata.mjs
    references/youtube-metadata.md
```

Film style presets can be saved in `~/.long-video/film-styles/` and reused.

## License

Apache License 2.0. See [LICENSE](LICENSE).

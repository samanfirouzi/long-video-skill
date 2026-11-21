# Install long-video

This file is for people and for AI coding tools. If you are an AI tool and the user gave you this repository's GitHub URL and asked you to install it, follow "For AI tools" below.

## For AI tools

Goal: install the skills in the `skills/` folder of this repository (12 folders, each with a `SKILL.md`) so that the user's AI coding tool can use them. Then make sure the tools the skills need are present.

### Rules

- Ask the user before you install anything. Show the exact commands first.
- Ask two questions, unless the user already answered them:
  1. Which AI coding tools should get the skills? (all that are installed, or a list)
  2. Install for every project (global) or for this project only?
- Never ask for, type or store passwords, tokens or API keys. If a system prompt asks for a password, tell the user to type it themselves.
- Do not run a script you have not told the user about.
- After installing, tell the user to restart their AI tool, then say "make a long video".

### Step 1: Find out which tool you are, and use its own installer

| Tool | Install command |
|------|-----------------|
| Claude Code | `claude plugin marketplace add samanfirouzi/long-video-skill` then `claude plugin install long-video@long-video`. Inside a session the same steps are `/plugin marketplace add samanfirouzi/long-video-skill` and `/plugin install long-video@long-video` |
| Gemini CLI | `gemini skills install https://github.com/samanfirouzi/long-video-skill.git --path skills --consent` (add `--scope workspace` for this project only). The `--path skills` part is required: Gemini looks for skills one folder level down |
| Codex | Use the built-in `$skill-installer`. Install every path `skills/long-video-assets`, `skills/long-video-clips`, `skills/long-video-director`, `skills/long-video-keyframes`, `skills/long-video-niche-discovery`, `skills/long-video-publish`, `skills/long-video-render`, `skills/long-video-setup`, `skills/long-video-sound`, `skills/long-video-story`, `skills/long-video-story-questions`, `skills/long-video-voice` from `samanfirouzi/long-video-skill`, with `--dest ~/.agents/skills` (Codex reads that folder). For this project only use `--dest <project>/.agents/skills` |
| Any other tool (Cursor, GitHub Copilot, OpenCode, Cline, Windsurf, Kiro, Goose, Amp, Qwen Code, Droid, Continue, and more) | Run the installer script below. It detects the tools and copies the skills to the right folders |

If your own installer is not available or fails, use the installer script.

### Step 2: The installer script (works for many tools at once)

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.ps1 | iex
```

macOS and Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.sh | bash
```

It finds the installed AI tools, lets the user choose some or all, asks global or project, copies the skills, checks ffmpeg, Node.js and git, and offers to install what is missing.

To run it without questions, after the user agreed to everything:

```powershell
$env:LONG_VIDEO_YES='1'; $env:LONG_VIDEO_AGENTS='all'; $env:LONG_VIDEO_SCOPE='global'; irm https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.ps1 | iex
```

```bash
curl -fsSL https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.sh | bash -s -- --yes --agents all --scope global
```

`--yes` also installs missing tools with the system package manager. Use it only if the user agreed to that.

Another cross-tool option: `npx skills add samanfirouzi/long-video-skill` (the open `skills` CLI, which supports many AI tools and asks which to use).

### Step 3: Check the tools the skills need

The skills need ffmpeg, ffprobe, Node.js 18 or newer, and git. The installer script checks them. If you installed with the tool's own installer, check them yourself:

```
ffmpeg -version
ffprobe -version
node --version
git --version
```

If any is missing, tell the user and offer to install it, with the user's yes:

| System | Command |
|--------|---------|
| Windows | `winget install Gyan.FFmpeg`, `winget install OpenJS.NodeJS.LTS`, `winget install Git.Git` |
| macOS | `brew install ffmpeg node git` |
| Debian or Ubuntu | `sudo apt-get install -y ffmpeg nodejs git` |
| Fedora | `sudo dnf install -y ffmpeg nodejs git` |

After winget installs, the terminal may need to be reopened to see the new tools. The first skill, `long-video-setup`, also checks these tools and offers to install what is missing.

### Step 4: Finish

1. Tell the user what was installed and where.
2. Tell the user to restart their AI tool.
3. Tell the user to say: `make a long video`.

## For people

Use whichever way you prefer. They all give the same result.

1. **Ask your AI tool.** Paste this to it: `Install the long-video skills from https://github.com/samanfirouzi/long-video-skill by following INSTALL.md`.
2. **One command.** Use the installer script from Step 2 above.
3. **Your tool's own command.** See the table in Step 1.

To remove the skills: run the installer again with `-Uninstall` (Windows) or `--uninstall` (macOS and Linux). Your videos and configs in `~/.long-video/` are kept.

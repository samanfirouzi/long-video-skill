# Requirements

Run these checks in Step 1 of `long-video-setup`. Use the shell the user has (PowerShell on Windows, bash elsewhere).

## Required

| Tool | Check | Why | Install hint |
|------|-------|-----|--------------|
| ffmpeg | `ffmpeg -version` | Assemble, encode and mix video and audio | Windows: `winget install Gyan.FFmpeg`. macOS: `brew install ffmpeg`. Linux: package manager |
| ffprobe | `ffprobe -version` | Read media duration and format (ships with ffmpeg) | Comes with ffmpeg |
| Node.js 18+ | `node --version` | Run render and helper tooling | Windows: `winget install OpenJS.NodeJS.LTS`. macOS: `brew install node` |
| git | `git --version` | Version projects, publish skills | Windows: `winget install Git.Git` |

Check the Node major version is 18 or higher.

### Install commands (only after the user says yes)

| System | Command |
|--------|---------|
| Windows | `winget install --id Gyan.FFmpeg -e`, `winget install --id OpenJS.NodeJS.LTS -e`, `winget install --id Git.Git -e` |
| macOS | `brew install ffmpeg node git` (if Homebrew is missing, point the user to https://brew.sh/) |
| Debian or Ubuntu | `sudo apt-get install -y ffmpeg nodejs git` |
| Fedora | `sudo dnf install -y ffmpeg nodejs git` |
| Arch | `sudo pacman -S --noconfirm ffmpeg nodejs npm git` |

The apt version of Node.js can be older than 18. If so, point the user to https://nodejs.org/.

## Environment

| Check | How | Pass when |
|-------|-----|-----------|
| Free disk space | Windows: `Get-PSDrive` for the profile drive. Unix: `df -h ~` | At least 20 GB free. Long videos make large intermediate files |
| Write access | Create and delete a temp file in `~/.long-video/` | File is created and removed |

## Conditional

Check these only after the Q&A shows they are needed.

| Needed when | Check |
|-------------|-------|
| Python-based tools chosen | `python --version` (3.10+) |
| Cloud TTS provider chosen | The env var named by the user is set. Check with `$env:NAME` (PowerShell) or `echo $NAME` (bash). Print only "set" or "not set", never the value |
| Cloud image or video generator chosen | Same env var check |
| Local GPU generation chosen | `nvidia-smi` shows a GPU with enough memory for the chosen model |
| YouTube upload chosen | Credentials file path exists |

## Reporting format

```
Requirements
  ffmpeg      ok   7.1
  ffprobe     ok   7.1
  node        ok   v22.11
  git         ok   2.47
  disk        ok   142 GB free
```

If anything required fails, list only the failures after the table, each with its install hint.

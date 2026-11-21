# Instructions for AI coding tools

This repository holds a set of agent skills (`skills/*/SKILL.md`) for making long videos.

- If the user asks you to install these skills, read and follow [INSTALL.md](INSTALL.md).
- If the user asks you to work on the skills themselves, each skill is a folder under `skills/` with a `SKILL.md` (front matter: `name` equal to the folder name, `description`) and optional `references/` and `scripts/` folders. Keep `README.md` and `INSTALL.md` in step with any change.
- Helper scripts (`skills/long-video-sound/scripts/mix-cues.mjs`, `skills/long-video-render/scripts/build-render.mjs`, `skills/long-video-publish/scripts/check-metadata.mjs`) need only Node 18+ and ffmpeg.
- Files that contain only ASCII characters are safer for the installers (`install.ps1`, `install.sh`).

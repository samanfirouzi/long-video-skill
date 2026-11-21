# Sound tools

Three outside tools support `long-video-sound`. Each is optional. Read this file in Step 2.

Facts below come from each project's own README and skill files. The tools change, so run `--help` and read their docs before first use, and trust them over this file where they differ.

## 1. Openverse: find real recordings and music

- What: a search engine for openly licensed media (https://openverse.org, source: https://github.com/WordPress/openverse). Audio includes sound effects and music, each with licence data.
- Use it for: real recorded sounds and background music.
- Interface: the public API at `https://api.openverse.org/v1/audio/`. Full docs: https://api.openverse.org/v1/

### Access

- Scripted requests without credentials may be stopped by a bot check. **Never try to get around a bot check or CAPTCHA.** Use registered credentials, or ask the user to search the website and download the files themselves.
- Credentials are free. The user registers an application on the Openverse API and gets a client id and a client secret (steps in the API docs). The registration asks for a name and email: the user does it themselves. Do not enter their email for them.
- The user stores them in environment variables `OPENVERSE_CLIENT_ID` and `OPENVERSE_CLIENT_SECRET`. Check only whether they are set. Never ask for the values in chat.
- With credentials, request a token from the API (client credentials flow, see the docs), then send it as `Authorization: Bearer <token>`.

### Search

Parameters (verify names in the API docs before use):

| Need | Parameter |
|------|-----------|
| Words | `q` |
| Sound effects or music | `category=sound_effect` or `category=music` |
| Allowed use | `license_type=commercial` and `license_type=modification` |
| File type | `extension=mp3` or `wav` |
| Length | `length=shortest`, `short`, `medium` or `long` |
| Paging | `page`, `page_size` |

Each result includes a title, creator, licence and version, the file URL, the page URL, the duration and an attribution text. Keep all of it for `credits.md`.

### Licence rules

- Allowed: CC0, public domain mark, CC BY, and CC BY-SA only if the user accepts share-alike conditions for the video's sound (ask).
- Rejected: any NC (non-commercial) and any ND (no derivatives). Mixing and trimming a sound is a change.
- Unknown or missing licence: rejected.
- For CC BY and similar, the credit text must appear in the video description. `credits.md` holds it.
- Read the licence on the item's own page before final use. Record the page URL.

## 2. Earshot: make sounds, build sounds, understand sounds

- What: a tool that makes sound effects from a request in words, builds missing sounds from recorded parts, and listens to audio to describe and judge it. Source: https://github.com/Leonxlnx/earshot
- Runs on the CPU. It is a command line, a Python package, an MCP server and a Claude Code plugin.
- Its sounds are rendered by code from numbers learned from public domain recordings. The README says every sound it makes is the user's to use. Check the repo's licence section before publishing.

### Install (ask first, state the size)

```
pip install "earshot @ git+https://github.com/Leonxlnx/earshot"
```

- Install from GitHub. The name `earshot` on PyPI belongs to a different project.
- Python 3.10 or newer. The base install is about 350 MB and makes sounds, with no model download.
- Listening needs the `listen` extra: torch, transformers and two models (about 1.1 GB to download, 2.2 GB on disk). Add the `mcp` extra for the MCP server: `pip install "earshot[listen,mcp] @ git+https://github.com/Leonxlnx/earshot"`.
- Check the install: `earshot doctor`. Fetch the models now: `earshot doctor --fetch`.
- For many listening calls prefer the MCP server (the models stay loaded). Each separate command loads the models first (20 to 40 seconds).
- The repo also holds two agent skills (`earshot`, `real-sound`). They can be added with `npx skills add Leonxlnx/earshot`.

### Commands used by this stage

Make:

```
earshot make "a wooden door closing" -o sound/sources/door.wav
earshot make "three variations of a footstep on gravel" -o sound/sources/step.wav
earshot make "rain on a tin roof, 30 seconds" -o sound/sources/rain.wav
earshot build "a stampede of horses" -o stampede.wav --part "hundreds of hoofbeats, for 6 s, getting louder" --part "a low rumble under everything, soft"
```

- Name the thing first, then feelings, material, numbers. English only (German partly).
- Read the first output line: it says whether the sound is `clean`, and says plainly when the catalogue has no such sound.
- Ask for 6 to 12 takes of any sound that repeats.
- `earshot make --set ui|game|arcade|film -o FOLDER` makes a whole family of sounds in one call.

Listen (needs the `listen` extra):

| Command | Use |
|---------|-----|
| `earshot describe FILE` | What a file sounds like, in tags and numbers |
| `earshot match FILE "a soft cork pop" --alts "..."` | How well a file fits a description |
| `earshot rank "QUERY" FILES...` | Sort candidate files by a description |
| `earshot find FILE "a single key press" --top 4` | Best moments inside a long recording (trim times) |
| `earshot realness FILES...` | Real recording or synthesized |
| `earshot measure FILE` | Loudness, peak, spectrum, tempo and key (no models) |
| `earshot timeline FILE [--video V] [--cues C]` | Events over time, sections, loudness, sync to picture and cues |
| `earshot critique FILE [--video V]` | Scorecard with timestamped fixes |

Use `--json` for full results. Errors print one line on stderr.

## 3. Clipwing real-sfx: place real sounds on exact frames

- What: a Claude skill that sound-designs motion videos with real recorded sounds placed on the exact frame, keeping music and voice. It writes a new MP4, a separate SFX WAV track, a cue report and a self-critique. Source: https://github.com/Clipwing/skills (folder `skills/real-sfx/`).
- It does not synthesize sound. It needs a sound library (`config.json` lists libraries) and ships 78 CC0 interface sounds. Folders of sounds downloaded from Openverse can be added as a library with its `setup.py add-library NAME PATH --index`.
- Input: an event list `[{"t": 1.2, "type": "click"}]`, with kinds such as whoosh, hit, riser, click, key, chime, wipe, pop. It is built for motion graphics, interface and promo videos.
- It expects a rendered video. This stage runs before final assembly, so use real-sfx mainly for motion-graphic style cues on a rendered preview, or after assembly. Story foley (footsteps, doors, nature) is better placed with the bundled `mix-cues.mjs`.

### Install (ask first)

Copy the folder `skills/real-sfx/` from the repo into `~/.claude/skills/real-sfx/` (all files, not only `SKILL.md`). Restart Claude Code. Then run `python scripts/setup.py check` from that folder. Read its `SKILL.md` before use.

## 4. The bundled mixer: `scripts/mix-cues.mjs`

Needs only Node and ffmpeg. Reads `sound/cues.json`, places every file on the timeline at its time, applies gain and fades, loops beds and music when asked, ducks music under speech regions with a smooth envelope, and writes `sfx_track.wav`, `amb_track.wav`, `music_track.wav` and `sound_preview.wav`.

```
node scripts/mix-cues.mjs sound/cues.json sound/mix
node scripts/mix-cues.mjs sound/cues.json sound/mix --plan
```

It stops with a list of problems if a file is missing or a cue time is outside the video. It warns when a file is shorter than the time it should fill and `loop` is not set.

## 5. Video editors with a CLI or MCP

If any video editor can be driven by a command line or an MCP server, Claude may use it to edit, place sound, grade and render. Check in this order: a connected editing MCP server in this session, then a CLI on the device (`<name> --help`). Examples found so far:

### FilmCraft (https://github.com/storytold/filmcraft)

- An open-source non-linear video editor in Rust (macOS, Windows, Linux, browser). Timeline, trimming, color, audio with ducking and loudness meters, titles and captions, export, interchange.
- Every action is a command (more than 650). The UI, the CLI, a JSON control channel and an MCP server all run the same commands.
- List commands: `filmcraft-cli commands`. MCP server (headless): `filmcraft-cli mcp`. App with control channel: `filmcraft --control 9876`.
- Example commands from its README: `timeline.place` (item, track, seconds, sourceIn, duration) and `effects.setParam`. Control protocol: `docs/control-protocol.md` in the repo.
- Get it from the Releases page, or build with Rust (`cargo run --release -p filmcraft-cli -- mcp`). The project calls itself young and moving fast, so read its docs first.

### EffectCraft (https://github.com/storytold/effectcraft)

- An open-source motion graphics and compositing tool in Rust. Layers, keyframes, effects, text, 3D, Lottie, render queue. Projects are readable JSON (`.ecproj`).
- Headless MCP: `effectcraft-cli mcp` (add `--bridge 9877` to attach to the running app). One-shot CLI calls with JSON output, for example `effectcraft-cli render --comp Main --out main.mp4`.
- Use it for animated titles, lower thirds and effects, not for the main timeline. Docs: `docs/agents.md`.

### Rules for any editor

- Ask before installing or building it, and say the size and time.
- Read the editor's own command list and docs first. Do not guess command names.
- Work on a copy of the project file. Never overwrite the user's project without asking.
- Keep file names from this workflow so assets stay findable.
- ffmpeg stays the fallback for anything the editor cannot do.

## 6. Music from a generator

If a connected tool or skill can generate music from a description, it may be used for the background music. Tell the user the cost first. Save the result in `sound/sources/`, then trim and fade it into `sound/cut/music_<NN>_<label>`. Record it in `credits.md` as "generated with <tool>". If the tool's terms limit commercial use, tell the user.

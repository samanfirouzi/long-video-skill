#!/usr/bin/env bash
# long-video installer for macOS and Linux (works with the old bash 3.2 that macOS ships)
#
# One command:
#   curl -fsSL https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.sh | bash
#
# What it does:
#   1. Finds which AI coding tools you use (Claude Code, Codex, Gemini CLI, Cursor, ...).
#   2. Lets you choose some of them, or all.
#   3. Asks where to install: all projects (global) or one project.
#   4. Installs the skills for every tool you chose.
#   5. Checks the tools the skills need (ffmpeg, Node.js, git) and offers to install missing ones.
# Nothing is installed without your yes.
#
# Options (add "-s --" after "bash" when you use the one-line command):
#   --scope global|project   --path /my/project   --agents all|claude-code,codex
#   --yes   --check   --uninstall   --list-agents
#   --repo owner/name   --branch main   --archive-url <tar.gz url or file:// path>
# --yes means: answer yes to every question (all detected tools, and installing missing tools).

set -eu

SCOPE="${LONG_VIDEO_SCOPE:-}"
PROJECT_PATH="${LONG_VIDEO_PATH:-}"
AGENTS_OPT="${LONG_VIDEO_AGENTS:-}"
YES="${LONG_VIDEO_YES:-0}"
CHECK_ONLY="${LONG_VIDEO_CHECK:-0}"
UNINSTALL="${LONG_VIDEO_UNINSTALL:-0}"
LIST_AGENTS=0
REPO="${LONG_VIDEO_REPO:-samanfirouzi/long-video-skill}"
BRANCH="${LONG_VIDEO_BRANCH:-main}"
ARCHIVE_URL="${LONG_VIDEO_ARCHIVE_URL:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    --scope) SCOPE="$2"; shift 2 ;;
    --path) PROJECT_PATH="$2"; shift 2 ;;
    --agents) AGENTS_OPT="$2"; shift 2 ;;
    --yes|-y) YES=1; shift ;;
    --check) CHECK_ONLY=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --list-agents) LIST_AGENTS=1; shift ;;
    --repo) REPO="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --archive-url) ARCHIVE_URL="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
done

# ---------- helpers ----------
say() { printf '%s\n' "$*"; }
ok() { printf '  [ok]      %s\n' "$*"; }
missing() { printf '  [missing] %s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
trim() { printf '%s' "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }
expand_home() { case "$1" in "~"*) printf '%s' "$HOME${1#\~}" ;; *) printf '%s' "$1" ;; esac; }

# Read an answer from the keyboard even when the script itself is piped in.
ask() {
  local prompt="$1" default="$2" answer=""
  if [ "$YES" != "1" ] && [ -r /dev/tty ] && [ -w /dev/tty ]; then
    printf '%s' "$prompt" >/dev/tty
    IFS= read -r answer </dev/tty || answer=""
  fi
  [ -z "$answer" ] && answer="$default"
  printf '%s' "$answer"
}

yesno() { # yesno "question" default(y|n)
  [ "$YES" = "1" ] && return 0
  local hint="Y/n" def="$2"
  [ "$def" = "n" ] && hint="y/N"
  local a; a="$(ask "$1 [$hint] " "$def")"
  case "$(lower "$a")" in y|yes) return 0 ;; *) return 1 ;; esac
}

node_ok() {
  have node || return 1
  local major; major="$(node --version | sed 's/^v//' | cut -d. -f1)"
  [ "${major:-0}" -ge 18 ]
}

OS="$(uname -s)"
case "$OS" in Darwin|Linux) ;; *) fail "This installer is for macOS and Linux. On Windows use install.ps1." ;; esac

# ---------- AI coding tools that read SKILL.md skills ----------
# Paths follow the open "skills" CLI table (https://github.com/vercel-labs/skills/blob/main/docs/agents.md).
# Columns: id | name | command that shows it is installed | settings folder | global skills folder | project skills folder
AGENT_TABLE='claude-code|Claude Code|claude|~/.claude|~/.claude/skills|.claude/skills
codex|Codex|codex|~/.codex|~/.agents/skills|.agents/skills
gemini-cli|Gemini CLI|gemini|~/.gemini|~/.gemini/skills|.agents/skills
cursor|Cursor|cursor|~/.cursor|~/.cursor/skills|.agents/skills
github-copilot|GitHub Copilot|copilot|~/.copilot|~/.copilot/skills|.agents/skills
opencode|OpenCode|opencode|~/.config/opencode|~/.config/opencode/skills|.agents/skills
windsurf|Windsurf|windsurf|~/.codeium/windsurf|~/.codeium/windsurf/skills|.windsurf/skills
cline|Cline|cline|~/.cline|~/.agents/skills|.agents/skills
roo|Roo Code||~/.roo|~/.roo/skills|.roo/skills
kiro-cli|Kiro CLI|kiro-cli|~/.kiro|~/.kiro/skills|.kiro/skills
amp|Amp|amp|~/.config/amp|~/.config/agents/skills|.agents/skills
goose|Goose|goose|~/.config/goose|~/.config/goose/skills|.goose/skills
qwen-code|Qwen Code|qwen|~/.qwen|~/.qwen/skills|.qwen/skills
droid|Droid|droid|~/.factory|~/.factory/skills|.agents/skills
continue|Continue||~/.continue|~/.continue/skills|.continue/skills'

A_ID=(); A_NAME=(); A_CMD=(); A_DIR=(); A_GLOBAL=(); A_PROJECT=()
while IFS='|' read -r id name cmd dir glob proj; do
  A_ID+=("$id"); A_NAME+=("$name"); A_CMD+=("$cmd"); A_DIR+=("$dir"); A_GLOBAL+=("$glob"); A_PROJECT+=("$proj")
done <<EOF
$AGENT_TABLE
EOF
N_AGENTS=${#A_ID[@]}

is_detected() { # is_detected index
  local i="$1"
  if [ -n "${A_CMD[$i]}" ] && have "${A_CMD[$i]}"; then return 0; fi
  [ -d "$(expand_home "${A_DIR[$i]}")" ]
}

if [ "$LIST_AGENTS" = "1" ]; then
  i=0
  while [ "$i" -lt "$N_AGENTS" ]; do
    found=""; is_detected "$i" && found="found"
    printf '%-16s %-15s %s\n' "${A_ID[$i]}" "${A_NAME[$i]}" "$found"
    i=$((i + 1))
  done
  exit 0
fi

say ""
say "long-video installer"
say "--------------------"

# ---------- 1. which AI tools ----------
DETECTED=()
i=0
while [ "$i" -lt "$N_AGENTS" ]; do
  if is_detected "$i"; then DETECTED+=("$i"); fi
  i=$((i + 1))
done
FALLBACK=0   # claude-code is the first row

say ""
if [ "${#DETECTED[@]}" -gt 0 ]; then
  say "AI coding tools found on this computer:"
  for i in "${DETECTED[@]}"; do ok "${A_NAME[$i]}"; done
else
  say "No AI coding tool was found automatically."
fi

SELECTED=()
is_selected() { case " ${SELECTED[*]:-} " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }
add_selected() { is_selected "$1" || SELECTED+=("$1"); }
find_agent() { # find_agent id-or-name -> index or empty
  local want i=0; want="$(lower "$1")"
  while [ "$i" -lt "$N_AGENTS" ]; do
    if [ "$want" = "${A_ID[$i]}" ] || [ "$want" = "$(lower "${A_NAME[$i]}")" ]; then printf '%s' "$i"; return; fi
    i=$((i + 1))
  done
}

if [ -n "$AGENTS_OPT" ]; then
  if [ "$AGENTS_OPT" = "all" ]; then
    if [ "${#DETECTED[@]}" -gt 0 ]; then for i in "${DETECTED[@]}"; do add_selected "$i"; done; else add_selected "$FALLBACK"; fi
  else
    OLDIFS="$IFS"; IFS=','
    for tok in $AGENTS_OPT; do
      IFS="$OLDIFS"; tok="$(trim "$tok")"
      idx="$(find_agent "$tok")"
      [ -n "$idx" ] || fail "Unknown tool '$tok'. Run with --list-agents to see the names."
      add_selected "$idx"
      IFS=','
    done
    IFS="$OLDIFS"
  fi
elif [ "$YES" = "1" ]; then
  if [ "${#DETECTED[@]}" -gt 0 ]; then for i in "${DETECTED[@]}"; do add_selected "$i"; done; else add_selected "$FALLBACK"; fi
else
  # A menu of the tools found (or of every supported tool when none was found).
  # The user types numbers (1,3), a name, "a" for all, or "m" to see every supported tool.
  MENU=()
  if [ "${#DETECTED[@]}" -gt 0 ]; then MENU=("${DETECTED[@]}"); else i=0; while [ "$i" -lt "$N_AGENTS" ]; do MENU+=("$i"); i=$((i + 1)); done; fi
  while [ "${#SELECTED[@]}" -eq 0 ]; do
    say ""
    say "Which tools should get the skills?"
    n=1
    for i in "${MENU[@]}"; do printf '  %2d) %s\n' "$n" "${A_NAME[$i]}"; n=$((n + 1)); done
    say "   a) All of the above"
    if [ "${#DETECTED[@]}" -gt 0 ] && [ "${#MENU[@]}" -lt "$N_AGENTS" ]; then say "   m) Show every supported tool"; fi
    def="1"; [ "${#DETECTED[@]}" -gt 0 ] && def="a"
    pick="$(lower "$(trim "$(ask "Type numbers separated by commas, or a for all [$def]: " "$def")")")"
    if { [ "$pick" = "m" ] || [ "$pick" = "more" ]; } && [ "${#MENU[@]}" -lt "$N_AGENTS" ]; then
      MENU=(); i=0; while [ "$i" -lt "$N_AGENTS" ]; do MENU+=("$i"); i=$((i + 1)); done
      continue
    fi
    if [ "$pick" = "a" ] || [ "$pick" = "all" ]; then for i in "${MENU[@]}"; do add_selected "$i"; done; break; fi
    handle_token() { # one number, or one tool id or name
      local tok="$1"
      [ -z "$tok" ] && return 0
      if printf '%s' "$tok" | grep -Eq '^[0-9]+$' && [ "$tok" -ge 1 ] && [ "$tok" -le "${#MENU[@]}" ]; then
        add_selected "${MENU[$((tok - 1))]}"
      else
        local idx; idx="$(find_agent "$tok")"
        if [ -n "$idx" ]; then add_selected "$idx"; else say "  I did not understand '$tok'."; fi
      fi
    }
    OLDIFS="$IFS"; IFS=','
    for part in $pick; do
      IFS="$OLDIFS"; part="$(trim "$part")"
      if printf '%s' "$part" | grep -Eq '^[0-9]+([[:space:]]+[0-9]+)+$'; then
        for tok in $part; do handle_token "$tok"; done   # "1 3" means two numbers
      else
        handle_token "$part"                              # a number, or a name such as "qwen code"
      fi
      IFS=','
    done
    IFS="$OLDIFS"
    [ "${#SELECTED[@]}" -eq 0 ] && say "Nothing selected. Try again."
  done
fi
[ "${#SELECTED[@]}" -gt 0 ] || fail "No tool selected. Nothing installed."

names=""
for i in "${SELECTED[@]}"; do names="${names:+$names, }${A_NAME[$i]}"; done
say ""
say "Installing for: $names"
say "Your tool is not in the list? Run:  npx skills add samanfirouzi/long-video-skill  (it supports many more tools)"

# ---------- 2. where to install ----------
if [ -z "$SCOPE" ]; then
  if [ "$YES" = "1" ]; then SCOPE="global"; else
    say ""
    say "Where should the skills be installed?"
    say "  1) Global: available in every project (recommended)"
    say "  2) This project only: available only in one folder"
    choice="$(ask "Choose 1 or 2 [1]: " "1")"
    if [ "$choice" = "2" ]; then SCOPE="project"; else SCOPE="global"; fi
  fi
fi
case "$SCOPE" in global|project) ;; *) fail "Scope must be 'global' or 'project'." ;; esac

PROJECT_ROOT=""
if [ "$SCOPE" = "project" ]; then
  if [ -z "$PROJECT_PATH" ]; then PROJECT_PATH="$(ask "Project folder [$PWD]: " "$PWD")"; fi
  [ -d "$PROJECT_PATH" ] || fail "Folder not found: $PROJECT_PATH"
  PROJECT_ROOT="$(cd "$PROJECT_PATH" && pwd)"
fi

# Several tools can share one folder: install there once.
T_DIR=(); T_NAMES=()
for i in "${SELECTED[@]}"; do
  if [ "$SCOPE" = "global" ]; then dest="$(expand_home "${A_GLOBAL[$i]}")"; else dest="$PROJECT_ROOT/${A_PROJECT[$i]}"; fi
  pos=-1; k=0
  while [ "$k" -lt "${#T_DIR[@]}" ]; do [ "${T_DIR[$k]}" = "$dest" ] && pos=$k; k=$((k + 1)); done
  if [ "$pos" -ge 0 ]; then T_NAMES[$pos]="${T_NAMES[$pos]}, ${A_NAME[$i]}"; else T_DIR+=("$dest"); T_NAMES+=("${A_NAME[$i]}"); fi
done
say ""
say "Install locations:"
k=0; while [ "$k" -lt "${#T_DIR[@]}" ]; do say "  ${T_DIR[$k]}   (${T_NAMES[$k]})"; k=$((k + 1)); done

# ---------- uninstall ----------
if [ "$UNINSTALL" = "1" ]; then
  FOUND=()
  for d in "${T_DIR[@]}"; do
    if [ -d "$d" ]; then
      while IFS= read -r f; do [ -n "$f" ] && FOUND+=("$f"); done < <(find "$d" -maxdepth 1 -mindepth 1 -type d -name 'long-video-*' | sort)
    fi
  done
  if [ "${#FOUND[@]}" -eq 0 ]; then say "Nothing to remove."; exit 0; fi
  say "This removes ${#FOUND[@]} skill folders. Your videos and configs in $HOME/.long-video are kept."
  if ! yesno "Remove them?" n; then say "Cancelled."; exit 0; fi
  for f in "${FOUND[@]}"; do rm -rf "$f"; done
  say "Removed."
  exit 0
fi

# ---------- 3. requirements ----------
say ""
say "Checking the tools the skills need..."
MISSING=()
check() { # check "label" "why" test-command
  if eval "$3"; then ok "$1"; else missing "$1${2:+: $2}"; MISSING+=("$1"); fi
}
check "ffmpeg" "cuts, joins and renders video and audio" "have ffmpeg"
check "ffprobe" "reads video and audio details (comes with ffmpeg)" "have ffprobe"
check "Node.js 18 or newer" "runs the helper scripts" "node_ok"
check "git" "saves and shares your projects" "have git"

install_missing() {
  local pkgs="" m
  for m in "${MISSING[@]}"; do
    case "$m" in
      ffmpeg|ffprobe) case " $pkgs " in *" ffmpeg "*) ;; *) pkgs="$pkgs ffmpeg" ;; esac ;;
      Node*) pkgs="$pkgs node" ;;
      git) pkgs="$pkgs git" ;;
    esac
  done
  pkgs="$(trim "$pkgs")"

  if [ "$OS" = "Darwin" ]; then
    if ! have brew; then
      say ""
      say "Homebrew (the macOS package installer) was not found, so I cannot install these for you."
      say "Install Homebrew from https://brew.sh/ and run this installer again, or install by hand:"
      say "  ffmpeg: https://ffmpeg.org/download.html   Node.js: https://nodejs.org/   git: https://git-scm.com/"
      return 0
    fi
    say ""
    if yesno "Install the missing tools now with Homebrew ($pkgs)?" y; then
      for p in $pkgs; do say "Installing $p ..."; brew install "$p" || say "  brew could not install $p."; done
    else say "Skipped. The skills will ask for these tools when they need them."; fi
    return 0
  fi

  # Linux
  local mgr="" names="" p
  if have apt-get; then mgr="apt"; elif have dnf; then mgr="dnf"; elif have pacman; then mgr="pacman"; elif have zypper; then mgr="zypper"; fi
  if [ -z "$mgr" ]; then
    say ""
    say "I could not find a package manager (apt, dnf, pacman, zypper). Install ffmpeg, Node.js 18+ and git by hand."
    return 0
  fi
  for p in $pkgs; do
    case "$p" in
      node) if [ "$mgr" = "pacman" ]; then names="$names nodejs npm"; else names="$names nodejs"; fi ;;
      *) names="$names $p" ;;
    esac
  done
  names="$(trim "$names")"
  local SUDO=""; if [ "$(id -u)" -ne 0 ] && have sudo; then SUDO="sudo"; fi
  say ""
  say "This will run: $SUDO $mgr install $names"
  say "Your computer may ask for your password. Type it yourself; this installer never sees it."
  if yesno "Install the missing tools now?" y; then
    case "$mgr" in
      apt) $SUDO apt-get update && $SUDO apt-get install -y $names || say "  The package manager reported an error." ;;
      dnf) $SUDO dnf install -y $names || say "  The package manager reported an error." ;;
      pacman) $SUDO pacman -S --noconfirm $names || say "  The package manager reported an error." ;;
      zypper) $SUDO zypper install -y $names || say "  The package manager reported an error." ;;
    esac
    if have node && ! node_ok; then
      say ""
      say "The Node.js your system installed is older than version 18. Install a newer one from https://nodejs.org/ (or with nvm), then run the check again."
    fi
  else say "Skipped. The skills will ask for these tools when they need them."; fi
  return 0
}

if [ "${#MISSING[@]}" -gt 0 ] && [ "$CHECK_ONLY" != "1" ]; then
  install_missing
  say ""
  say "Checking again..."
  MISSING=()
  hash -r
  check "ffmpeg" "" "have ffmpeg"; check "ffprobe" "" "have ffprobe"; check "Node.js 18 or newer" "" "node_ok"; check "git" "" "have git"
fi
[ "$CHECK_ONLY" = "1" ] && exit 0

# ---------- 4. find the skills ----------
SOURCE=""
HERE=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; fi
if [ -n "$HERE" ] && [ -d "$HERE/skills" ]; then
  SOURCE="$HERE/skills"
  say ""
  say "Using the skills next to this installer: $SOURCE"
else
  URL="$ARCHIVE_URL"
  if [ -z "$URL" ]; then
    URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
  fi
  have curl || have wget || fail "Need curl or wget to download the skills."
  have tar || fail "Need tar to open the download."
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  say ""
  say "Downloading $URL"
  if have curl; then curl -fsSL "$URL" -o "$TMP/repo.tar.gz"; else wget -q "$URL" -O "$TMP/repo.tar.gz"; fi
  tar -xzf "$TMP/repo.tar.gz" -C "$TMP"
  SOURCE=""
  while IFS= read -r d; do
    if [ -f "$d/long-video-setup/SKILL.md" ]; then SOURCE="$d"; break; fi
  done < <(find "$TMP" -type d -name skills | sort)
  [ -n "$SOURCE" ] || fail "The download does not contain the skills folder."
fi

# ---------- 5. copy the skills ----------
SKILLS=()
while IFS= read -r d; do if [ -f "$d/SKILL.md" ]; then SKILLS+=("$d"); fi; done < <(find "$SOURCE" -maxdepth 1 -mindepth 1 -type d | sort)
[ "${#SKILLS[@]}" -gt 0 ] || fail "No skills found to install."

EXISTING=0
for dest in "${T_DIR[@]}"; do
  for d in "${SKILLS[@]}"; do if [ -e "$dest/$(basename "$d")" ]; then EXISTING=$((EXISTING + 1)); fi; done
done
BACKUP_ROOT="$HOME/.long-video/backups/$(date +%Y%m%d-%H%M%S)"
if [ "$EXISTING" -gt 0 ]; then
  say ""
  say "$EXISTING skill folders are already installed. They will be replaced with this version."
  if ! yesno "Replace them? (the old copies are saved first)" y; then say "Cancelled. Nothing changed."; exit 0; fi
fi

for dest in "${T_DIR[@]}"; do
  mkdir -p "$dest"
  tag="$(printf '%s' "$dest" | sed 's/[^A-Za-z0-9]/_/g')"
  for d in "${SKILLS[@]}"; do
    name="$(basename "$d")"
    if [ -e "$dest/$name" ]; then mkdir -p "$BACKUP_ROOT/$tag"; mv "$dest/$name" "$BACKUP_ROOT/$tag/$name"; fi
    cp -R "$d" "$dest/$name"
  done
  ok "${#SKILLS[@]} skills installed in $dest"
done

# ---------- 6. data folders ----------
mkdir -p "$HOME/.long-video/configs" "$HOME/.long-video/projects" "$HOME/.long-video/film-styles"

# ---------- done ----------
say ""
say "Done. ${#SKILLS[@]} skills installed for: $names"
if [ "$EXISTING" -gt 0 ]; then say "Old copies saved in $BACKUP_ROOT"; fi
say ""
say "Next:"
say "  1. Restart your AI coding tool so it sees the new skills."
say "  2. Say:  make a long video"
say ""
say "Note: the skills were written and tested with Claude Code. Other tools read the same files, but steps that use"
say "MCP servers or a browser depend on what that tool offers."
say ""

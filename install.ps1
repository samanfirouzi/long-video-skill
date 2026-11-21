# long-video installer for Windows (PowerShell 5.1 or newer)
#
# One command:
#   irm https://raw.githubusercontent.com/samanfirouzi/long-video-skill/main/install.ps1 | iex
#
# What it does:
#   1. Finds which AI coding tools you use (Claude Code, Codex, Gemini CLI, Cursor, ...).
#   2. Lets you choose some of them, or all.
#   3. Asks where to install: all projects (global) or one project.
#   4. Installs the skills for every tool you chose.
#   5. Checks the tools the skills need (ffmpeg, Node.js, git) and offers to install missing ones.
# Nothing is installed without your yes.
#
# Options (when you run the file itself, for example:
#   powershell -ExecutionPolicy Bypass -File .\install.ps1 -Scope global -Agents all):
#   -Scope global|project   -Path C:\my\project   -Agents all|claude-code,codex
#   -Yes   -CheckOnly   -Uninstall   -ListAgents
# Options through environment variables (when you use the one-line command):
#   LONG_VIDEO_SCOPE, LONG_VIDEO_PATH, LONG_VIDEO_AGENTS, LONG_VIDEO_YES=1, LONG_VIDEO_CHECK=1,
#   LONG_VIDEO_UNINSTALL=1, LONG_VIDEO_REPO=owner/name, LONG_VIDEO_BRANCH=main,
#   LONG_VIDEO_ARCHIVE_URL=<zip url> (use a mirror or a local file instead of GitHub)
# -Yes means: answer yes to every question (all detected tools, and installing missing tools).
#
# This script never calls "exit", so it does not close your PowerShell window when run with "| iex".

# ---------- options ----------
$script:Scope = $env:LONG_VIDEO_SCOPE
$script:Path = $env:LONG_VIDEO_PATH
$script:AgentsOpt = $env:LONG_VIDEO_AGENTS
$script:Yes = ($env:LONG_VIDEO_YES -eq '1')
$script:CheckOnly = ($env:LONG_VIDEO_CHECK -eq '1')
$script:Uninstall = ($env:LONG_VIDEO_UNINSTALL -eq '1')
$script:ListAgents = $false
$script:Repo = if ($env:LONG_VIDEO_REPO) { $env:LONG_VIDEO_REPO } else { 'samanfirouzi/long-video-skill' }
$script:Branch = if ($env:LONG_VIDEO_BRANCH) { $env:LONG_VIDEO_BRANCH } else { 'main' }
$script:ArchiveUrl = $env:LONG_VIDEO_ARCHIVE_URL

for ($i = 0; $i -lt $args.Count; $i++) {
    switch -Regex ($args[$i]) {
        '^-Scope$'      { $script:Scope = $args[++$i] }
        '^-Path$'       { $script:Path = $args[++$i] }
        '^-Agents$'     { $script:AgentsOpt = $args[++$i] }
        '^-Yes$'        { $script:Yes = $true }
        '^-CheckOnly$'  { $script:CheckOnly = $true }
        '^-Uninstall$'  { $script:Uninstall = $true }
        '^-ListAgents$' { $script:ListAgents = $true }
        '^-Repo$'       { $script:Repo = $args[++$i] }
        '^-Branch$'     { $script:Branch = $args[++$i] }
        default         { Write-Host "Unknown option: $($args[$i])" -ForegroundColor Yellow }
    }
}
$script:ScriptDir = $PSScriptRoot

# ---------- helpers ----------
function Say($text) { Write-Host $text }
function Ok($text) { Write-Host "  [ok]      $text" -ForegroundColor Green }
function Missing($text) { Write-Host "  [missing] $text" -ForegroundColor Yellow }
function Stop-Install($text) { throw $text }

function Ask-Text($question, $default) {
    if ($script:Yes) { return $default }
    try { $a = Read-Host $question } catch { return $default }
    if ([string]::IsNullOrWhiteSpace($a)) { return $default }
    return $a.Trim()
}

function Ask-YesNo($question, $default = $true) {
    if ($script:Yes) { return $true }
    $hint = if ($default) { 'Y/n' } else { 'y/N' }
    try { $answer = Read-Host "$question [$hint]" } catch { return $default }
    if ([string]::IsNullOrWhiteSpace($answer)) { return $default }
    return ($answer.Trim().ToLower() -in @('y', 'yes'))
}

function Refresh-Path {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Have($cmd) { return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

function Node-Ok {
    if (-not (Have 'node')) { return $false }
    try {
        $v = (& node --version).TrimStart('v')
        return ([int]($v.Split('.')[0]) -ge 18)
    } catch { return $false }
}

function Expand-Home($p) { if ($p.StartsWith('~')) { return (Join-Path $HOME $p.Substring(1).TrimStart('/', '\')) } else { return $p } }

# ---------- AI coding tools that read SKILL.md skills ----------
# Paths follow the open "skills" CLI table (https://github.com/vercel-labs/skills/blob/main/docs/agents.md).
# Cmd = command that shows the tool is installed. Dir = settings folder it creates.
$script:Agents = @(
    @{ Id = 'claude-code';    Name = 'Claude Code';    Cmd = 'claude';   Dir = '~/.claude';              Global = '~/.claude/skills';              Project = '.claude/skills' },
    @{ Id = 'codex';          Name = 'Codex';          Cmd = 'codex';    Dir = '~/.codex';               Global = '~/.agents/skills';              Project = '.agents/skills' },
    @{ Id = 'gemini-cli';     Name = 'Gemini CLI';     Cmd = 'gemini';   Dir = '~/.gemini';              Global = '~/.gemini/skills';              Project = '.agents/skills' },
    @{ Id = 'cursor';         Name = 'Cursor';         Cmd = 'cursor';   Dir = '~/.cursor';              Global = '~/.cursor/skills';              Project = '.agents/skills' },
    @{ Id = 'github-copilot'; Name = 'GitHub Copilot'; Cmd = 'copilot';  Dir = '~/.copilot';             Global = '~/.copilot/skills';             Project = '.agents/skills' },
    @{ Id = 'opencode';       Name = 'OpenCode';       Cmd = 'opencode'; Dir = '~/.config/opencode';     Global = '~/.config/opencode/skills';     Project = '.agents/skills' },
    @{ Id = 'windsurf';       Name = 'Windsurf';       Cmd = 'windsurf'; Dir = '~/.codeium/windsurf';    Global = '~/.codeium/windsurf/skills';    Project = '.windsurf/skills' },
    @{ Id = 'cline';          Name = 'Cline';          Cmd = 'cline';    Dir = '~/.cline';               Global = '~/.agents/skills';              Project = '.agents/skills' },
    @{ Id = 'roo';            Name = 'Roo Code';       Cmd = '';         Dir = '~/.roo';                 Global = '~/.roo/skills';                 Project = '.roo/skills' },
    @{ Id = 'kiro-cli';       Name = 'Kiro CLI';       Cmd = 'kiro-cli'; Dir = '~/.kiro';                Global = '~/.kiro/skills';                Project = '.kiro/skills' },
    @{ Id = 'amp';            Name = 'Amp';            Cmd = 'amp';      Dir = '~/.config/amp';          Global = '~/.config/agents/skills';       Project = '.agents/skills' },
    @{ Id = 'goose';          Name = 'Goose';          Cmd = 'goose';    Dir = '~/.config/goose';        Global = '~/.config/goose/skills';        Project = '.goose/skills' },
    @{ Id = 'qwen-code';      Name = 'Qwen Code';      Cmd = 'qwen';     Dir = '~/.qwen';                Global = '~/.qwen/skills';                Project = '.qwen/skills' },
    @{ Id = 'droid';          Name = 'Droid';          Cmd = 'droid';    Dir = '~/.factory';             Global = '~/.factory/skills';             Project = '.agents/skills' },
    @{ Id = 'continue';       Name = 'Continue';       Cmd = '';         Dir = '~/.continue';            Global = '~/.continue/skills';            Project = '.continue/skills' }
)

function Is-Detected($a) {
    if ($a.Cmd -and (Have $a.Cmd)) { return $true }
    return (Test-Path (Expand-Home $a.Dir))
}

function Install-LongVideo {
    if ($script:ListAgents) {
        foreach ($a in $script:Agents) { Say ("{0,-16} {1,-15} {2}" -f $a.Id, $a.Name, $(if (Is-Detected $a) { 'found' } else { '' })) }
        return
    }

    Say ''
    Say 'long-video installer'
    Say '--------------------'

    # ---------- 1. which AI tools ----------
    $detected = @($script:Agents | Where-Object { Is-Detected $_ })
    $fallback = @($script:Agents | Where-Object { $_.Id -eq 'claude-code' })
    Say ''
    if ($detected.Count -gt 0) {
        Say 'AI coding tools found on this computer:'
        foreach ($a in $detected) { Ok $a.Name }
    } else {
        Say 'No AI coding tool was found automatically.'
    }

    $selected = @()
    if ($script:AgentsOpt) {
        if ($script:AgentsOpt -eq 'all') { $selected = if ($detected.Count -gt 0) { $detected } else { $fallback } }
        else {
            foreach ($id in ($script:AgentsOpt.Split(',') | ForEach-Object { $_.Trim() })) {
                $m = $script:Agents | Where-Object { $_.Id -eq $id }
                if (-not $m) { Stop-Install "Unknown tool '$id'. Run with -ListAgents to see the names." }
                $selected += $m
            }
        }
    } elseif ($script:Yes) {
        $selected = if ($detected.Count -gt 0) { $detected } else { $fallback }
    } else {
        # A menu of the tools found (or of every supported tool when none was found).
        # The user types numbers (1,3), a name, "a" for all, or "m" to see every supported tool.
        $menu = if ($detected.Count -gt 0) { $detected } else { $script:Agents }
        while ($selected.Count -eq 0) {
            Say ''
            Say 'Which tools should get the skills?'
            for ($i = 0; $i -lt $menu.Count; $i++) { Say ("  {0,2}) {1}" -f ($i + 1), $menu[$i].Name) }
            Say '   a) All of the above'
            if ($detected.Count -gt 0 -and $menu.Count -lt $script:Agents.Count) { Say '   m) Show every supported tool' }
            $def = if ($detected.Count -gt 0) { 'a' } else { '1' }
            $pick = (Ask-Text "Type numbers separated by commas, or a for all [$def]" $def).ToLower()
            if ($pick -in @('m', 'more') -and $menu.Count -lt $script:Agents.Count) { $menu = $script:Agents; continue }
            if ($pick -in @('a', 'all')) { $selected = @($menu); break }
            $tokens = @()
            foreach ($part in ($pick -split ',')) {
                $part = $part.Trim()
                if ($part -match '^\d+(\s+\d+)+$') { $tokens += ($part -split '\s+') } elseif ($part) { $tokens += $part }
            }
            foreach ($tok in $tokens) {
                $idx = 0
                if ([int]::TryParse($tok, [ref]$idx) -and $idx -ge 1 -and $idx -le $menu.Count) { $selected += $menu[$idx - 1] }
                else {
                    $byName = $menu | Where-Object { $_.Id -eq $tok -or $_.Name.ToLower() -eq $tok }
                    if ($byName) { $selected += $byName } else { Say "  I did not understand '$tok'." }
                }
            }
            $seen = @{}; $unique = @()
            foreach ($s in $selected) { if (-not $seen.ContainsKey($s.Id)) { $seen[$s.Id] = $true; $unique += $s } }
            $selected = $unique
            if ($selected.Count -eq 0) { Say 'Nothing selected. Try again.' }
        }
    }
    if ($selected.Count -eq 0) { Stop-Install 'No tool selected. Nothing installed.' }
    Say ''
    Say ("Installing for: " + (($selected | ForEach-Object { $_.Name }) -join ', '))
    Say 'Your tool is not in the list? Run:  npx skills add samanfirouzi/long-video-skill  (it supports many more tools)'

    # ---------- 2. where to install ----------
    $scope = $script:Scope
    if (-not $scope) {
        if ($script:Yes) { $scope = 'global' }
        else {
            Say ''
            Say 'Where should the skills be installed?'
            Say '  1) Global: available in every project (recommended)'
            Say '  2) This project only: available only in one folder'
            $choice = Ask-Text 'Choose 1 or 2 [1]' '1'
            $scope = if ($choice -eq '2') { 'project' } else { 'global' }
        }
    }
    if ($scope -notin @('global', 'project')) { Stop-Install "Scope must be 'global' or 'project'." }

    $projectRoot = $null
    if ($scope -eq 'project') {
        $p = $script:Path
        if (-not $p) { $p = Ask-Text "Project folder [$((Get-Location).Path)]" (Get-Location).Path }
        if (-not (Test-Path $p)) { Stop-Install "Folder not found: $p" }
        $projectRoot = (Resolve-Path $p).Path
    }

    # Several tools can share one folder: install there once.
    $targets = [ordered]@{}
    foreach ($a in $selected) {
        $dest = if ($scope -eq 'global') { Expand-Home $a.Global } else { Join-Path $projectRoot ($a.Project -replace '/', '\') }
        if (-not $targets.Contains($dest)) { $targets[$dest] = @() }
        $targets[$dest] += $a.Name
    }
    Say ''
    Say 'Install locations:'
    foreach ($d in $targets.Keys) { Say ("  {0}   ({1})" -f $d, ($targets[$d] -join ', ')) }

    # ---------- uninstall ----------
    if ($script:Uninstall) {
        $found = @()
        foreach ($d in $targets.Keys) {
            if (Test-Path $d) { $found += @(Get-ChildItem $d -Directory -Filter 'long-video-*') }
        }
        if ($found.Count -eq 0) { Say 'Nothing to remove.'; return }
        Say "This removes $($found.Count) skill folders. Your videos and configs in $HOME\.long-video are kept."
        if (-not (Ask-YesNo 'Remove them?' $false)) { Say 'Cancelled.'; return }
        foreach ($d in $found) { Remove-Item $d.FullName -Recurse -Force }
        Say 'Removed.'
        return
    }

    # ---------- 3. requirements ----------
    Say ''
    Say 'Checking the tools the skills need...'
    $need = @(
        @{ Name = 'ffmpeg';  Test = { Have 'ffmpeg' };  Winget = 'Gyan.FFmpeg';        Why = 'cuts, joins and renders video and audio' },
        @{ Name = 'ffprobe'; Test = { Have 'ffprobe' }; Winget = 'Gyan.FFmpeg';        Why = 'reads video and audio details (comes with ffmpeg)' },
        @{ Name = 'Node.js 18 or newer'; Test = { Node-Ok }; Winget = 'OpenJS.NodeJS.LTS'; Why = 'runs the helper scripts' },
        @{ Name = 'git';     Test = { Have 'git' };     Winget = 'Git.Git';            Why = 'saves and shares your projects' }
    )
    $missing = @()
    foreach ($n in $need) {
        if (& $n.Test) { Ok $n.Name } else { Missing "$($n.Name): $($n.Why)"; $missing += $n }
    }

    if ($missing.Count -gt 0 -and -not $script:CheckOnly) {
        $ids = @($missing | ForEach-Object { $_.Winget } | Select-Object -Unique)
        Say ''
        if (-not (Have 'winget')) {
            Say 'winget (the Windows package installer) was not found, so I cannot install these for you.'
            Say 'Install them by hand, then run this installer again:'
            Say '  ffmpeg:  https://www.gyan.dev/ffmpeg/builds/'
            Say '  Node.js: https://nodejs.org/'
            Say '  git:     https://git-scm.com/download/win'
        } elseif (Ask-YesNo "Install the missing tools now with winget ($($ids -join ', '))?") {
            foreach ($id in $ids) {
                Say "Installing $id ..."
                & winget install --id $id -e --accept-source-agreements --accept-package-agreements
                if ($LASTEXITCODE -ne 0) { Write-Host "  winget could not install $id (exit $LASTEXITCODE)." -ForegroundColor Yellow }
            }
            Refresh-Path
            Say ''
            Say 'Checking again...'
            $still = @()
            foreach ($n in $need) {
                if (& $n.Test) { Ok $n.Name } else { Missing $n.Name; $still += $n.Name }
            }
            if ($still.Count -gt 0) {
                Say ''
                Say 'Some tools are installed but not visible yet. Close this window, open a new one, and run the installer again to check.'
            }
        } else {
            Say 'Skipped. The skills will ask for these tools when they need them.'
        }
    }
    if ($script:CheckOnly) { return }

    # ---------- 4. find the skills ----------
    $source = $null
    if ($script:ScriptDir -and (Test-Path (Join-Path $script:ScriptDir 'skills'))) {
        $source = Join-Path $script:ScriptDir 'skills'
        Say ''
        Say "Using the skills next to this installer: $source"
    } else {
        $url = $script:ArchiveUrl
        if (-not $url) {
            $url = "https://github.com/$($script:Repo)/archive/refs/heads/$($script:Branch).zip"
        }
        $tmp = Join-Path ([IO.Path]::GetTempPath()) ("long-video-" + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $tmp | Out-Null
        $zip = Join-Path $tmp 'repo.zip'
        Say ''
        Say "Downloading $url"
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
        } catch { Stop-Install "Download failed: $($_.Exception.Message)" }
        Expand-Archive -Path $zip -DestinationPath $tmp -Force
        $hit = Get-ChildItem $tmp -Recurse -Directory -Filter 'skills' | Where-Object { Test-Path (Join-Path $_.FullName 'long-video-setup\SKILL.md') } | Select-Object -First 1
        if (-not $hit) { Stop-Install 'The download does not contain the skills folder.' }
        $source = $hit.FullName
    }

    # ---------- 5. copy the skills ----------
    $skills = @(Get-ChildItem $source -Directory | Where-Object { Test-Path (Join-Path $_.FullName 'SKILL.md') })
    if ($skills.Count -eq 0) { Stop-Install 'No skills found to install.' }

    $replace = @()
    foreach ($d in $targets.Keys) {
        foreach ($s in $skills) { if (Test-Path (Join-Path $d $s.Name)) { $replace += (Join-Path $d $s.Name) } }
    }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path $HOME ".long-video\backups\$stamp"
    if ($replace.Count -gt 0) {
        Say ''
        Say "$($replace.Count) skill folders are already installed. They will be replaced with this version."
        if (-not (Ask-YesNo 'Replace them? (the old copies are saved first)')) { Say 'Cancelled. Nothing changed.'; return }
    }

    foreach ($d in $targets.Keys) {
        New-Item -ItemType Directory -Force -Path $d | Out-Null
        $tag = ($d -replace '[:\\/ ]', '_')
        foreach ($s in $skills) {
            $target = Join-Path $d $s.Name
            if (Test-Path $target) {
                $bk = Join-Path $backupRoot $tag
                New-Item -ItemType Directory -Force -Path $bk | Out-Null
                Move-Item $target (Join-Path $bk $s.Name)
            }
            Copy-Item $s.FullName $target -Recurse
        }
        Ok "$($skills.Count) skills installed in $d"
    }

    # ---------- 6. data folders ----------
    foreach ($d in @('configs', 'projects', 'film-styles')) {
        New-Item -ItemType Directory -Force -Path (Join-Path $HOME ".long-video\$d") | Out-Null
    }

    # ---------- done ----------
    Say ''
    Write-Host "Done. $($skills.Count) skills installed for: $(($selected | ForEach-Object { $_.Name }) -join ', ')" -ForegroundColor Green
    if ($replace.Count -gt 0) { Say "Old copies saved in $backupRoot" }
    Say ''
    Say 'Next:'
    Say '  1. Restart your AI coding tool so it sees the new skills.'
    Say '  2. Say:  make a long video'
    Say ''
    Say 'Note: the skills were written and tested with Claude Code. Other tools read the same files, but steps that use'
    Say 'MCP servers or a browser depend on what that tool offers.'
    Say ''
}

try {
    Install-LongVideo
} catch {
    Write-Host ''
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    $global:LASTEXITCODE = 1
}

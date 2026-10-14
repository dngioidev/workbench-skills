# workbench-skills Repo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A public repo that ships workbench skills to Claude Code via a plugin marketplace and via `install.ps1` / `install.sh` scripts with global or project scope.

**Architecture:** The repo root is both a Claude plugin marketplace and the plugin itself; `skills/<name>/SKILL.md` is the single source of truth. Two dependency-free installer scripts (PowerShell 5.1+/7, Bash 3.2+) copy those skill folders into `~/.claude/skills/` or `<project>/.claude/skills/`, using the local clone when present and otherwise downloading the GitHub archive.

**Tech Stack:** PowerShell 5.1 / 7, Bash 3.2+ (macOS default), curl, tar, GitHub Actions, Claude Code plugin manifests (JSON).

**Spec:** `docs/superpowers/specs/2026-10-14-workbench-skills-repo-design.md`

## Global Constraints

- GitHub repo: `dngioidev/workbench-skills`; default branch `main`.
- Marketplace name `workbench-skills`; plugin name `workbench`; plugin source `./`.
- License: MIT, `Copyright (c) 2026 dngioidev`.
- Install targets: global → `~/.claude/skills/`; project → `<path>/.claude/skills/` (default path: current directory).
- Flags — PowerShell: `-Scope global|project`, `-Path <dir>`, `-Ref <git-ref>` (default `main`), `-Uninstall`. Bash: `--scope`, `--path`, `--ref`, `--uninstall`.
- Install replaces only same-named skill folders; uninstall removes only this repo's skill names. Nothing else in the target is touched.
- No scope + no interactive input → exit non-zero with a message showing the flag. Never guess.
- Temp directories are removed on success and failure.
- `install.ps1` must run on Windows PowerShell 5.1 (no `??`, `?:`, `&&`, `-AsHashtable`) and on PowerShell 7.
- `install.sh` must run on Bash 3.2 (macOS) and Git Bash on Windows; stored with LF line endings.
- No runtime dependencies beyond what ships with the OS (+ curl/tar for Bash).
- Test-only env override: `WORKBENCH_ARCHIVE` = local archive file path or URL, used in place of the GitHub archive URL.

## Review Focus

1. **Project paths containing spaces** (e.g. `C:\Users\Jane Doe\my app`) — install must work; tests use a `my project` directory.
2. **Remote mode with no local `skills/`** (`curl … | bash -s --`, `& ([scriptblock]::Create((irm …)))`) — must download, extract, install; tests run the piped/scriptblock form against a local archive via `WORKBENCH_ARCHIVE`.
3. **`irm … | iex` form** — the script (with its `param()` block) must parse under `Invoke-Expression`, and on failure must never call `exit` (that would close the user's console); test pipes the script into `Invoke-Expression` and checks for the clean "no -Scope given" message.
4. **Bad inputs fail cleanly without side effects** — nonexistent project path creates nothing; missing/unreachable archive reports "download failed" and installs nothing.
5. **Uninstall when nothing is installed** (or target folder missing) — exits 0 and reports 0 removed.

---

## File Structure

| File | Responsibility |
|---|---|
| `.gitattributes` | Force LF for `*.sh`, CRLF for `*.ps1` |
| `LICENSE` | MIT license text |
| `.claude-plugin/marketplace.json` | Marketplace listing the `workbench` plugin at `./` |
| `.claude-plugin/plugin.json` | Plugin metadata |
| `skills/workbench-hello/SKILL.md` | Placeholder skill to exercise installs (removed when real skills land) |
| `install.sh` | Bash installer |
| `tests/test-install.sh` | Bash installer smoke tests |
| `install.ps1` | PowerShell installer |
| `tests/test-install.ps1` | PowerShell installer smoke tests |
| `.github/workflows/test.yml` | CI: both test suites on Windows/Linux/macOS + manifest JSON check |
| `README.md` | User docs |

---

### Task 1: Repo scaffold, placeholder skill, plugin manifests

**Files:**
- Create: `.gitattributes`, `LICENSE`, `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json`, `skills/workbench-hello/SKILL.md`

**Interfaces:**
- Consumes: nothing.
- Produces: `skills/<name>/SKILL.md` layout that Tasks 2–3 install; at least one skill (`workbench-hello`) exists for tests.

- [ ] **Step 1: Create `.gitattributes`**

```gitattributes
* text=auto
*.sh text eol=lf
*.ps1 text eol=crlf
```

- [ ] **Step 2: Create `LICENSE`**

```text
MIT License

Copyright (c) 2026 dngioidev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 3: Create `.claude-plugin/marketplace.json`**

```json
{
  "name": "workbench-skills",
  "owner": {
    "name": "dngioidev"
  },
  "metadata": {
    "description": "Skills that save AI agent work into a per-ticket workbench folder.",
    "version": "0.1.0"
  },
  "plugins": [
    {
      "name": "workbench",
      "source": "./",
      "description": "Save agent work into a workbench/ folder organized by ticket (Jira, Azure DevOps, GitHub Projects, ...).",
      "version": "0.1.0"
    }
  ]
}
```

- [ ] **Step 4: Create `.claude-plugin/plugin.json`**

```json
{
  "name": "workbench",
  "version": "0.1.0",
  "description": "Save agent work into a workbench/ folder organized by ticket (Jira, Azure DevOps, GitHub Projects, ...).",
  "author": {
    "name": "dngioidev"
  },
  "homepage": "https://github.com/dngioidev/workbench-skills",
  "repository": "https://github.com/dngioidev/workbench-skills",
  "license": "MIT",
  "keywords": ["workbench", "tickets", "jira", "azure-devops", "github-projects"]
}
```

- [ ] **Step 5: Create `skills/workbench-hello/SKILL.md`**

```markdown
---
name: workbench-hello
description: Placeholder that confirms workbench-skills is installed. Use only when the user asks to check whether the workbench skills are installed.
---

# Workbench Hello

Reply with exactly: `workbench-skills is installed.`
```

- [ ] **Step 6: Validate the manifests**

Run: `claude plugin validate .`
Expected: validation passes with no errors. If the `claude` CLI is not on PATH, run instead:
`powershell -NoProfile -Command "Get-Content -Raw .claude-plugin/marketplace.json | ConvertFrom-Json | Out-Null; Get-Content -Raw .claude-plugin/plugin.json | ConvertFrom-Json | Out-Null; 'ok'"`
Expected: `ok`.

- [ ] **Step 7: Commit**

```bash
git add .gitattributes LICENSE .claude-plugin skills
git commit -m "feat: add plugin manifests and placeholder skill" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: Bash installer

**Files:**
- Create: `install.sh`
- Test: `tests/test-install.sh`

**Interfaces:**
- Consumes: `skills/<name>/SKILL.md` from Task 1.
- Produces: `install.sh [--scope global|project] [--path DIR] [--ref REF] [--uninstall]`; exit 0 on success, 1 on any error (message on stderr prefixed `error: `). Honors `WORKBENCH_ARCHIVE`. Archive layout expected: one top-level dir containing `skills/`.

- [ ] **Step 1: Write the failing test `tests/test-install.sh`**

```bash
#!/usr/bin/env bash
# Smoke tests for install.sh. Run: bash tests/test-install.sh
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
installer="$repo/install.sh"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

check() {
  local name="$1"; shift
  if "$@"; then echo "PASS $name"; else echo "FAIL $name"; failures=$((failures + 1)); fi
}
runs_ok() { "$@" >/dev/null 2>&1; }
fails() { ! "$@" >/dev/null 2>&1; }

skills=()
for d in "$repo"/skills/*/; do skills+=("$(basename "$d")"); done
all_installed() { for s in "${skills[@]}"; do [ -f "$1/$s/SKILL.md" ] || return 1; done; }
none_installed() { for s in "${skills[@]}"; do [ ! -e "$1/$s" ] || return 1; done; }

# Project install into a path with a space, next to a foreign skill
proj="$work/my project"
target="$proj/.claude/skills"
mkdir -p "$target/foreign"
echo keep > "$target/foreign/SKILL.md"

check "project install exits 0" runs_ok bash "$installer" --scope project --path "$proj"
check "project install copies every skill" all_installed "$target"
check "foreign skill survives install" test -f "$target/foreign/SKILL.md"

# Re-run replaces a modified file
first="${skills[0]}"
echo tampered > "$target/$first/SKILL.md"
check "re-run exits 0" runs_ok bash "$installer" --scope project --path "$proj"
check "re-run restores modified file" cmp -s "$repo/skills/$first/SKILL.md" "$target/$first/SKILL.md"

# Uninstall
check "uninstall exits 0" runs_ok bash "$installer" --scope project --path "$proj" --uninstall
check "uninstall removes repo skills" none_installed "$target"
check "uninstall keeps foreign skill" test -f "$target/foreign/SKILL.md"
check "uninstall with nothing installed exits 0" runs_ok bash "$installer" --scope project --path "$proj" --uninstall
check "uninstall with missing target exits 0" runs_ok bash "$installer" --scope project --path "$work" --uninstall

# Global install writes under HOME
fakehome="$work/home"
mkdir -p "$fakehome"
check "global install exits 0" runs_ok env HOME="$fakehome" bash "$installer" --scope global
check "global install writes under HOME" all_installed "$fakehome/.claude/skills"

# Bad input
check "invalid scope fails" fails bash "$installer" --scope nowhere
check "unknown argument fails" fails bash "$installer" --bogus
check "missing project path fails" fails bash "$installer" --scope project --path "$work/nope"
check "missing project path creates nothing" test ! -e "$work/nope"
check "no scope without a terminal fails" fails bash "$installer" </dev/null

# Remote mode: script piped into bash, no local skills/
mkdir -p "$work/pkg/workbench-skills-main"
cp -R "$repo/skills" "$work/pkg/workbench-skills-main/"
tar -czf "$work/archive.tar.gz" -C "$work/pkg" workbench-skills-main
remote="$work/remote"
mkdir -p "$remote"
check "piped remote install exits 0" runs_ok env WORKBENCH_ARCHIVE="$work/archive.tar.gz" \
  bash -c 'bash -s -- --scope project --path "$1" < "$2"' _ "$remote" "$installer"
check "piped remote install copies every skill" all_installed "$remote/.claude/skills"

broken="$work/broken"
mkdir -p "$broken"
check "missing archive fails" fails env WORKBENCH_ARCHIVE="$work/missing.tar.gz" \
  bash -c 'bash -s -- --scope project --path "$1" < "$2"' _ "$broken" "$installer"
check "missing archive installs nothing" none_installed "$broken/.claude/skills"

if [ "$failures" -gt 0 ]; then echo "$failures test(s) failed"; exit 1; fi
echo "All tests passed"
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/test-install.sh`
Expected: multiple `FAIL` lines (e.g. `FAIL project install exits 0`) and `N test(s) failed`, exit 1 — `install.sh` does not exist yet.

- [ ] **Step 3: Write `install.sh`**

```bash
#!/usr/bin/env bash
# Install workbench skills for Claude Code.
# Usage: install.sh [--scope global|project] [--path DIR] [--ref REF] [--uninstall]
set -euo pipefail

REPO="dngioidev/workbench-skills"
scope=""
path=""
ref="main"
uninstall=0

usage() {
  cat <<'EOF'
Install workbench skills for Claude Code.

Usage: install.sh [--scope global|project] [--path DIR] [--ref REF] [--uninstall]

  --scope global    install to ~/.claude/skills
  --scope project   install to <DIR>/.claude/skills (DIR defaults to current directory)
  --path DIR        project root for --scope project
  --ref REF         branch or tag to download when not run from a clone (default: main)
  --uninstall       remove this repo's skills from the target
EOF
}

die() { echo "error: $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --scope) [ $# -ge 2 ] || die "--scope needs a value"; scope="$2"; shift 2 ;;
    --path) [ $# -ge 2 ] || die "--path needs a value"; path="$2"; shift 2 ;;
    --ref) [ $# -ge 2 ] || die "--ref needs a value"; ref="$2"; shift 2 ;;
    --uninstall) uninstall=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (see --help)" ;;
  esac
done

if [ -z "$scope" ]; then
  if [ -t 0 ]; then
    printf 'Install workbench skills to:\n  [1] Global  (~/.claude/skills)\n  [2] Project (%s/.claude/skills)\n' "${path:-$PWD}"
    read -r -p 'Choice [1/2]: ' choice
    case "$choice" in
      1) scope=global ;;
      2) scope=project ;;
      *) die "invalid choice: $choice (expected 1 or 2)" ;;
    esac
  else
    die "no --scope given and no terminal to ask. Re-run with: curl -fsSL https://raw.githubusercontent.com/$REPO/main/install.sh | bash -s -- --scope global"
  fi
fi
scope="$(printf '%s' "$scope" | tr '[:upper:]' '[:lower:]')"

case "$scope" in
  global) target="$HOME/.claude/skills" ;;
  project)
    project_dir="${path:-.}"
    [ -d "$project_dir" ] || die "project path does not exist: $project_dir"
    target="$(cd "$project_dir" && pwd)/.claude/skills"
    ;;
  *) die "invalid scope: $scope (expected global or project)" ;;
esac

tmp=""
cleanup() { if [ -n "$tmp" ]; then rm -rf "$tmp"; fi; }
trap cleanup EXIT

script_dir=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -n "$script_dir" ] && [ -d "$script_dir/skills" ]; then
  src="$script_dir/skills"
else
  tmp="$(mktemp -d)"
  archive="${WORKBENCH_ARCHIVE:-https://github.com/$REPO/archive/$ref.tar.gz}"
  echo "Downloading $archive"
  if [ -f "$archive" ]; then
    cp "$archive" "$tmp/src.tar.gz"
  else
    curl -fsSL "$archive" -o "$tmp/src.tar.gz" || die "download failed: $archive"
  fi
  tar -xzf "$tmp/src.tar.gz" -C "$tmp" || die "could not extract archive"
  src=""
  for d in "$tmp"/*/skills; do
    if [ -d "$d" ]; then src="$d"; break; fi
  done
  [ -n "$src" ] || die "archive has no skills/ directory"
fi

skills=()
for d in "$src"/*/; do
  if [ -f "$d/SKILL.md" ]; then skills+=("$(basename "$d")"); fi
done
[ ${#skills[@]} -gt 0 ] || die "no skills found in $src"

if [ "$uninstall" -eq 1 ]; then
  removed=0
  for name in "${skills[@]}"; do
    if [ -d "$target/$name" ]; then
      rm -rf "${target:?}/$name"
      echo "  removed $name"
      removed=$((removed + 1))
    fi
  done
  echo "Removed $removed skill(s) from $target"
else
  mkdir -p "$target" 2>/dev/null || die "cannot create target: $target"
  [ -w "$target" ] || die "target is not writable: $target"
  for name in "${skills[@]}"; do
    rm -rf "${target:?}/$name"
    cp -R "$src/$name" "$target/$name" || die "copy failed: $name"
    echo "  installed $name"
  done
  echo "Installed ${#skills[@]} skill(s) to $target"
  if [ "$scope" = project ]; then
    echo "Tip: commit .claude/skills/ to share these skills with your team."
  fi
fi
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bash tests/test-install.sh`
Expected: every line `PASS …`, final line `All tests passed`, exit 0.

- [ ] **Step 5: Mark scripts executable and commit**

```bash
git add install.sh tests/test-install.sh
git update-index --chmod=+x install.sh tests/test-install.sh
git commit -m "feat: add bash installer with global/project scope" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: PowerShell installer

**Files:**
- Create: `install.ps1`
- Test: `tests/test-install.ps1`

**Interfaces:**
- Consumes: `skills/<name>/SKILL.md` from Task 1.
- Produces: `install.ps1 [-Scope global|project] [-Path <dir>] [-Ref <ref>] [-Uninstall]`. Errors print `error: <message>` via `Write-Host`; exit code 1 only when run as a file (`-File` / `./install.ps1`), never under `iex` or a scriptblock. Honors `$env:WORKBENCH_ARCHIVE` (local `.zip` path or URL). Archive layout expected: one top-level dir containing `skills/`.

- [ ] **Step 1: Write the failing test `tests/test-install.ps1`**

```powershell
# Smoke tests for install.ps1. Run: powershell -NoProfile -File tests/test-install.ps1
$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repo 'install.ps1'
$ps = (Get-Process -Id $PID).Path
$work = Join-Path ([IO.Path]::GetTempPath()) ('wb-test-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $work | Out-Null
$script:failures = 0

function Check([string]$Name, [bool]$Ok) {
    if ($Ok) { Write-Host "PASS $Name" } else { Write-Host "FAIL $Name"; $script:failures++ }
}

# Runs a script in a fresh non-interactive process and returns its output; exit code is in $LASTEXITCODE.
function Invoke-Ps([string[]]$Arguments) {
    & $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File @Arguments | Out-String
}

$skills = @(Get-ChildItem -LiteralPath (Join-Path $repo 'skills') -Directory | ForEach-Object { $_.Name })

function Test-AllInstalled([string]$Dir) {
    foreach ($s in $skills) {
        if (-not (Test-Path -LiteralPath (Join-Path (Join-Path $Dir $s) 'SKILL.md'))) { return $false }
    }
    return $true
}

function Test-NoneInstalled([string]$Dir) {
    foreach ($s in $skills) {
        if (Test-Path -LiteralPath (Join-Path $Dir $s)) { return $false }
    }
    return $true
}

try {
    # Project install into a path with a space, next to a foreign skill
    $proj = Join-Path $work 'my project'
    $target = Join-Path (Join-Path $proj '.claude') 'skills'
    $foreign = Join-Path $target 'foreign'
    New-Item -ItemType Directory -Path $foreign -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $foreign 'SKILL.md') -Value 'keep'

    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj) | Out-Null
    Check 'project install exits 0' ($LASTEXITCODE -eq 0)
    Check 'project install copies every skill' (Test-AllInstalled $target)
    Check 'foreign skill survives install' (Test-Path -LiteralPath (Join-Path $foreign 'SKILL.md'))

    # Re-run replaces a modified file
    $first = $skills[0]
    $installedFile = Join-Path (Join-Path $target $first) 'SKILL.md'
    $sourceFile = Join-Path (Join-Path (Join-Path $repo 'skills') $first) 'SKILL.md'
    Set-Content -LiteralPath $installedFile -Value 'tampered'
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj) | Out-Null
    Check 're-run exits 0' ($LASTEXITCODE -eq 0)
    Check 're-run restores modified file' ((Get-FileHash -LiteralPath $installedFile).Hash -eq (Get-FileHash -LiteralPath $sourceFile).Hash)

    # Uninstall
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj, '-Uninstall') | Out-Null
    Check 'uninstall exits 0' ($LASTEXITCODE -eq 0)
    Check 'uninstall removes repo skills' (Test-NoneInstalled $target)
    Check 'uninstall keeps foreign skill' (Test-Path -LiteralPath (Join-Path $foreign 'SKILL.md'))
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $proj, '-Uninstall') | Out-Null
    Check 'uninstall with nothing installed exits 0' ($LASTEXITCODE -eq 0)
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $work, '-Uninstall') | Out-Null
    Check 'uninstall with missing target exits 0' ($LASTEXITCODE -eq 0)

    # Global install writes under the user's home ($HOME comes from USERPROFILE on Windows, HOME elsewhere)
    $fakeHome = Join-Path $work 'home'
    New-Item -ItemType Directory -Path $fakeHome | Out-Null
    $savedProfile = $env:USERPROFILE
    $savedHome = $env:HOME
    $env:USERPROFILE = $fakeHome
    $env:HOME = $fakeHome
    Invoke-Ps @($installer, '-Scope', 'global') | Out-Null
    $globalCode = $LASTEXITCODE
    $env:USERPROFILE = $savedProfile
    $env:HOME = $savedHome
    Check 'global install exits 0' ($globalCode -eq 0)
    Check 'global install writes under home' (Test-AllInstalled (Join-Path (Join-Path $fakeHome '.claude') 'skills'))

    # Bad input
    Invoke-Ps @($installer, '-Scope', 'nowhere') | Out-Null
    Check 'invalid scope fails' ($LASTEXITCODE -eq 1)
    $missing = Join-Path $work 'nope'
    Invoke-Ps @($installer, '-Scope', 'project', '-Path', $missing) | Out-Null
    Check 'missing project path fails' ($LASTEXITCODE -eq 1)
    Check 'missing project path creates nothing' (-not (Test-Path -LiteralPath $missing))
    $out = Invoke-Ps @($installer)
    Check 'no scope without a console fails' ($LASTEXITCODE -eq 1)
    Check 'no scope message names -Scope' ($out -match 'no -Scope given')

    # Remote mode: scriptblock form, wrapper lives in $work so there is no local skills/
    $pkg = Join-Path (Join-Path $work 'pkg') 'workbench-skills-main'
    New-Item -ItemType Directory -Path $pkg -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $repo 'skills') -Destination $pkg -Recurse
    $zip = Join-Path $work 'archive.zip'
    Compress-Archive -Path $pkg -DestinationPath $zip

    $sbWrapper = Join-Path $work 'run-scriptblock.ps1'
    Set-Content -LiteralPath $sbWrapper -Value @'
param($Archive, $Installer, $Target)
$env:WORKBENCH_ARCHIVE = $Archive
& ([scriptblock]::Create((Get-Content -Raw -LiteralPath $Installer))) -Scope project -Path $Target
'@
    $remote = Join-Path $work 'remote'
    New-Item -ItemType Directory -Path $remote | Out-Null
    Invoke-Ps @($sbWrapper, $zip, $installer, $remote) | Out-Null
    Check 'scriptblock remote install copies every skill' (Test-AllInstalled (Join-Path (Join-Path $remote '.claude') 'skills'))

    $broken = Join-Path $work 'broken'
    New-Item -ItemType Directory -Path $broken | Out-Null
    $out = Invoke-Ps @($sbWrapper, (Join-Path $work 'missing.zip'), $installer, $broken)
    Check 'missing archive reports download failed' ($out -match 'download failed')
    Check 'missing archive installs nothing' (Test-NoneInstalled (Join-Path (Join-Path $broken '.claude') 'skills'))

    # irm | iex form: must parse and fail cleanly when it cannot prompt
    $iexWrapper = Join-Path $work 'run-iex.ps1'
    Set-Content -LiteralPath $iexWrapper -Value @'
param($Installer)
Get-Content -Raw -LiteralPath $Installer | Invoke-Expression
'@
    $out = Invoke-Ps @($iexWrapper, $installer)
    Check 'iex form parses and asks for -Scope' ($out -match 'no -Scope given')
}
finally {
    Remove-Item -LiteralPath $work -Recurse -Force
}

if ($script:failures -gt 0) {
    Write-Host "$($script:failures) test(s) failed"
    exit 1
}
Write-Host 'All tests passed'
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-install.ps1`
Expected: multiple `FAIL` lines and `N test(s) failed`, exit 1 — `install.ps1` does not exist yet.

- [ ] **Step 3: Write `install.ps1`**

```powershell
<#
.SYNOPSIS
    Install workbench skills for Claude Code.
.DESCRIPTION
    Copies every skill in skills/ into ~/.claude/skills (global) or <project>/.claude/skills
    (project). Re-run to update; use -Uninstall to remove. When not run from a clone, downloads
    the repo archive from GitHub.
.EXAMPLE
    ./install.ps1 -Scope project -Path D:\my-app
.EXAMPLE
    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/dngioidev/workbench-skills/main/install.ps1))) -Scope global
#>
[CmdletBinding()]
param(
    [string]$Scope,
    [string]$Path,
    [string]$Ref = 'main',
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$Repo = 'dngioidev/workbench-skills'
# Only set an exit code when run as a file; under `irm | iex`, exit would close the user's console.
$RunAsFile = $MyInvocation.MyCommand.CommandType -eq 'ExternalScript'
$LocalSkills = if ($PSScriptRoot) { Join-Path $PSScriptRoot 'skills' } else { $null }

function Test-Interactive {
    if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) { return $false }
    $nonInteractive = [Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-noni*' }
    return -not $nonInteractive
}

function Resolve-Scope([string]$Value, [string]$ProjectPath) {
    if ($Value) { return $Value }
    if (-not (Test-Interactive)) {
        throw "no -Scope given and no console to ask. Re-run with: & ([scriptblock]::Create((irm https://raw.githubusercontent.com/$Repo/main/install.ps1))) -Scope global"
    }
    $here = if ($ProjectPath) { $ProjectPath } else { (Get-Location).Path }
    Write-Host 'Install workbench skills to:'
    Write-Host '  [1] Global  (~/.claude/skills)'
    Write-Host "  [2] Project ($here/.claude/skills)"
    switch (Read-Host 'Choice [1/2]') {
        '1' { return 'global' }
        '2' { return 'project' }
        default { throw 'invalid choice (expected 1 or 2)' }
    }
}

function Resolve-Target([string]$ScopeValue, [string]$ProjectPath) {
    switch ($ScopeValue) {
        'global' { return Join-Path (Join-Path $HOME '.claude') 'skills' }
        'project' {
            if (-not $ProjectPath) { $ProjectPath = (Get-Location).Path }
            if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
                throw "project path does not exist: $ProjectPath"
            }
            $root = (Resolve-Path -LiteralPath $ProjectPath).ProviderPath
            return Join-Path (Join-Path $root '.claude') 'skills'
        }
        default { throw "invalid scope: '$ScopeValue' (expected global or project)" }
    }
}

function Get-RemoteSkills([string]$GitRef, [string]$Temp) {
    $archive = if ($env:WORKBENCH_ARCHIVE) { $env:WORKBENCH_ARCHIVE } else { "https://github.com/$Repo/archive/$GitRef.zip" }
    $zip = Join-Path $Temp 'src.zip'
    Write-Host "Downloading $archive"
    try {
        if (Test-Path -LiteralPath $archive -PathType Leaf) {
            Copy-Item -LiteralPath $archive -Destination $zip
        } else {
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $archive -OutFile $zip -UseBasicParsing
        }
    } catch {
        throw "download failed: $archive ($($_.Exception.Message))"
    }
    try {
        Expand-Archive -LiteralPath $zip -DestinationPath $Temp -Force
    } catch {
        throw "could not extract archive: $($_.Exception.Message)"
    }
    foreach ($dir in Get-ChildItem -LiteralPath $Temp -Directory) {
        $candidate = Join-Path $dir.FullName 'skills'
        if (Test-Path -LiteralPath $candidate -PathType Container) { return $candidate }
    }
    throw 'archive has no skills/ directory'
}

function Invoke-Main {
    $scopeValue = Resolve-Scope $Scope $Path
    $target = Resolve-Target $scopeValue $Path
    $temp = $null
    try {
        if ($LocalSkills -and (Test-Path -LiteralPath $LocalSkills -PathType Container)) {
            $source = $LocalSkills
        } else {
            $temp = Join-Path ([IO.Path]::GetTempPath()) ('workbench-skills-' + [guid]::NewGuid())
            New-Item -ItemType Directory -Path $temp | Out-Null
            $source = Get-RemoteSkills $Ref $temp
        }

        $skills = @(Get-ChildItem -LiteralPath $source -Directory |
            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') })
        if ($skills.Count -eq 0) { throw "no skills found in $source" }

        if ($Uninstall) {
            $removed = 0
            foreach ($skill in $skills) {
                $dest = Join-Path $target $skill.Name
                if (Test-Path -LiteralPath $dest) {
                    Remove-Item -LiteralPath $dest -Recurse -Force
                    Write-Host "  removed $($skill.Name)"
                    $removed++
                }
            }
            Write-Host "Removed $removed skill(s) from $target"
        } else {
            try {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
            } catch {
                throw "cannot create target: $target"
            }
            foreach ($skill in $skills) {
                $dest = Join-Path $target $skill.Name
                if (Test-Path -LiteralPath $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
                Copy-Item -LiteralPath $skill.FullName -Destination $dest -Recurse
                Write-Host "  installed $($skill.Name)"
            }
            Write-Host "Installed $($skills.Count) skill(s) to $target"
            if ($scopeValue -eq 'project') {
                Write-Host 'Tip: commit .claude/skills/ to share these skills with your team.'
            }
        }
    } finally {
        if ($temp -and (Test-Path -LiteralPath $temp)) { Remove-Item -LiteralPath $temp -Recurse -Force }
    }
}

$failed = $false
try {
    Invoke-Main
} catch {
    Write-Host "error: $($_.Exception.Message)" -ForegroundColor Red
    $failed = $true
}
if ($failed -and $RunAsFile) { exit 1 }
```

- [ ] **Step 4: Run the tests to verify they pass (Windows PowerShell 5.1)**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-install.ps1`
Expected: every line `PASS …`, final line `All tests passed`, exit 0.

- [ ] **Step 5: Run the tests under PowerShell 7 if installed**

Run: `pwsh -NoProfile -File tests/test-install.ps1` (skip if `pwsh` is not on PATH; CI covers it)
Expected: `All tests passed`.

- [ ] **Step 6: Commit**

```bash
git add install.ps1 tests/test-install.ps1
git commit -m "feat: add PowerShell installer with global/project scope" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: CI workflow and README

**Files:**
- Create: `.github/workflows/test.yml`, `README.md`

**Interfaces:**
- Consumes: `tests/test-install.sh`, `tests/test-install.ps1`, `.claude-plugin/*.json`, flags from Tasks 2–3.
- Produces: user-facing docs; CI that gates pushes and PRs.

- [ ] **Step 1: Create `.github/workflows/test.yml`**

```yaml
name: test

on:
  push:
    branches: [main]
  pull_request:

jobs:
  bash:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Bash installer tests
        shell: bash
        run: bash tests/test-install.sh

  powershell:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Windows PowerShell 5.1 installer tests
        if: runner.os == 'Windows'
        shell: powershell
        run: ./tests/test-install.ps1
      - name: PowerShell 7 installer tests
        shell: pwsh
        run: ./tests/test-install.ps1

  manifests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Manifests are valid JSON
        run: jq empty .claude-plugin/marketplace.json .claude-plugin/plugin.json
```

- [ ] **Step 2: Create `README.md`**

````markdown
# workbench-skills

Skills that make AI coding agents save their work into a `workbench/` folder inside your
project, organized by ticket (Jira, Azure DevOps, GitHub Projects, ...).

Currently supports **Claude Code**. Codex and Antigravity support is planned.

## Skills

| Skill | What it does |
|---|---|
| `workbench-hello` | Placeholder that confirms the install works. |

## Install

### Option A: Claude Code plugin

In Claude Code:

```text
/plugin marketplace add dngioidev/workbench-skills
/plugin install workbench@workbench-skills
```

Plugin skills are namespaced, e.g. `/workbench:workbench-hello`. Update with
`/plugin marketplace update workbench-skills`.

### Option B: Install script (global or project)

- **Global** installs to `~/.claude/skills/` — available in every project.
- **Project** installs to `<project>/.claude/skills/` — commit it to share with your team.

Script-installed skills are not namespaced, e.g. `/workbench-hello`.

**Windows (PowerShell)** — interactive:

```powershell
irm https://raw.githubusercontent.com/dngioidev/workbench-skills/main/install.ps1 | iex
```

With options:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/dngioidev/workbench-skills/main/install.ps1))) -Scope project -Path .
```

**macOS / Linux / Git Bash:**

```bash
curl -fsSL https://raw.githubusercontent.com/dngioidev/workbench-skills/main/install.sh | bash -s -- --scope global
```

```bash
curl -fsSL https://raw.githubusercontent.com/dngioidev/workbench-skills/main/install.sh | bash -s -- --scope project --path .
```

**From a clone:**

```bash
git clone https://github.com/dngioidev/workbench-skills.git
cd workbench-skills
./install.sh --scope project --path ~/my-app     # or: ./install.ps1 -Scope project -Path D:\my-app
```

| PowerShell | Bash | Meaning |
|---|---|---|
| `-Scope global\|project` | `--scope global\|project` | Where to install. Prompted if omitted (interactive only). |
| `-Path <dir>` | `--path <dir>` | Project root for project scope. Default: current directory. |
| `-Ref <ref>` | `--ref <ref>` | Branch or tag to download. Default: `main`. |
| `-Uninstall` | `--uninstall` | Remove this repo's skills from the target. |

### Update and uninstall

Re-run the same install command to update — each skill folder is replaced with the latest
version. Add `-Uninstall` / `--uninstall` to remove them. Other skills in the target folder
are never touched.

## Adding a skill

1. Create `skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. Put any supporting files the skill references next to it in the same folder.
3. Add a row to the Skills table above.
4. Run the tests: `bash tests/test-install.sh` and `powershell -File tests/test-install.ps1`.

## License

[MIT](LICENSE)
````

- [ ] **Step 3: Run both test suites once more**

Run: `bash tests/test-install.sh` then `powershell -NoProfile -ExecutionPolicy Bypass -File tests/test-install.ps1`
Expected: both end with `All tests passed`.

- [ ] **Step 4: Verify the plugin installs locally**

In an interactive Claude Code session (user runs this; it changes Claude settings):
`/plugin marketplace add D:\dngioi\workbench-skills` then `/plugin install workbench@workbench-skills`
Expected: `/workbench:workbench-hello` appears in the skill list. Remove afterwards with
`/plugin marketplace remove workbench-skills`.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/test.yml README.md
git commit -m "docs: add README and CI workflow" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

## After the plan

Creating the GitHub repo `dngioidev/workbench-skills` and pushing `main` is an outward-facing
step for the owner to approve separately; the remote one-liners and CI only work after that.

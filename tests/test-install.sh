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

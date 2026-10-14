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

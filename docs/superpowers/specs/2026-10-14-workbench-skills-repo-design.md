# workbench-skills — Repo Design

Date: 2026-10-14
Owner: dngioidev
Status: Draft for review

## Purpose

A public repo (`github.com/dngioidev/workbench-skills`) that stores and distributes
"workbench" skills: skills that instruct AI coding agents to save their work into a
`workbench/` folder inside a project, organized by ticket (Jira, Azure DevOps,
GitHub Projects, etc.).

The repo's job is **storage and easy installation**. Skill content is supplied by the
owner later and is out of scope for this design.

## Scope

- **In scope (v1):** Claude Code only. Two install routes: Claude plugin marketplace,
  and standalone installer scripts (PowerShell + Bash) supporting global or project scope.
- **Out of scope (v1):** Codex and Antigravity install targets, selective skill install,
  installed-version tracking, npm/pip packaging. The layout keeps `skills/` in the
  agent-neutral `SKILL.md` format so other agents can be added later by extending the
  installers only.

## Success criteria

1. `/plugin marketplace add dngioidev/workbench-skills` then `/plugin install workbench@workbench-skills`
   makes every skill in `skills/` available in Claude Code.
2. A one-liner (`irm … | iex` on Windows, `curl … | bash` elsewhere) installs all skills
   to either `~/.claude/skills/` or `<project>/.claude/skills/`, as the user chooses.
3. Re-running the installer updates skills in place; `--uninstall` removes only this
   repo's skills.
4. Installer smoke tests pass on Windows, Linux, and macOS in CI.

## Repo layout

```
workbench-skills/
├── .claude-plugin/
│   ├── marketplace.json   # marketplace "workbench-skills", one plugin "workbench", source "./"
│   └── plugin.json        # name "workbench", version, description, author, license, repo URL
├── skills/                # single source of truth
│   └── <skill-name>/
│       ├── SKILL.md       # YAML frontmatter (name, description) + instructions
│       └── ...            # optional supporting files referenced by SKILL.md
├── install.ps1
├── install.sh
├── tests/
│   ├── test-install.ps1
│   └── test-install.sh
├── .github/workflows/test.yml
├── README.md
└── LICENSE                # MIT
```

- The repo root is both the marketplace and the plugin. `skills/` is Claude's default
  plugin skills directory, so no extra plugin config is needed.
- Plugin-installed skills are namespaced (`/workbench:<skill>`); script-installed skills
  are not (`/<skill>`). This is Claude Code behavior and is documented in the README.
- Until the owner's skills arrive, `skills/` contains one placeholder skill
  (`workbench-hello`) used to exercise both install routes. It is removed when real
  skills are added.

## Installer behavior

`install.ps1` and `install.sh` have identical behavior and equivalent flags.

| PowerShell            | Bash                | Meaning                                         |
|-----------------------|---------------------|-------------------------------------------------|
| `-Scope global\|project` | `--scope global\|project` | Install target. Prompted if omitted.        |
| `-Path <dir>`         | `--path <dir>`      | Project root for project scope. Default: current directory. |
| `-Ref <git-ref>`      | `--ref <git-ref>`   | Branch/tag to download in remote mode. Default: `main`. |
| `-Uninstall`          | `--uninstall`       | Remove this repo's skills from the target.      |

Target directories:
- global → `~/.claude/skills/` (`$HOME\.claude\skills\` on Windows)
- project → `<path>/.claude/skills/`

### Flow

1. **Resolve scope.** If not given, prompt `[1] Global  [2] Project`. If no interactive
   input is available (piped execution without a TTY), exit non-zero with a message
   telling the user to pass the scope flag. Never guess.
2. **Resolve skill source.**
   - Local mode: if a `skills/` directory exists next to the script, use it.
   - Remote mode: otherwise, download
     `https://github.com/dngioidev/workbench-skills/archive/<ref>.zip` (PowerShell) or
     `.tar.gz` (Bash) into a temp directory and use its `skills/`.
3. **Install.** Create the target directory if missing. For each `skills/<name>/`,
   delete `<target>/<name>/` if present, then copy the folder. Other folders in the
   target are untouched. Re-running = update.
4. **Uninstall.** For each `skills/<name>/` in the source, delete `<target>/<name>/` if
   present. Nothing else is removed.
5. **Report.** Print each skill installed/removed and the target path. For project scope,
   print a hint that `.claude/skills/` can be committed to share with the team.

### Error handling

Exit non-zero with a clear message on: invalid scope value, project path that does not
exist, unwritable target, download/extract failure, or a source with no skills. Temp
directories are removed on both success and failure (`try/finally` in PowerShell,
`trap … EXIT` in Bash).

## Testing

- `tests/test-install.ps1` and `tests/test-install.sh` run the local-mode installer
  against a temp project directory and a temp `HOME`, asserting:
  1. project install creates `<tmp>/.claude/skills/<name>/SKILL.md` for every source skill;
  2. a pre-existing foreign skill folder in the target survives install;
  3. re-running install succeeds and replaces a modified installed file;
  4. uninstall removes only this repo's skills, leaving the foreign folder;
  5. global install writes under the temp `HOME`;
  6. an invalid scope exits non-zero.
- GitHub Actions runs both test scripts on `windows-latest`, `ubuntu-latest`,
  `macos-latest` (Bash tests also run under Git Bash on Windows).
- Plugin manifests are validated manually with `claude plugin validate .` before release.

## README contents

What the workbench skills do; list of skills (one line each); install via plugin;
install via script (global vs project, one-liners and flags); update and uninstall;
namespacing note; how to add a new skill (create `skills/<name>/SKILL.md`); license.

# workbench-skills

Skills that make AI coding agents save their work into a workbench folder inside your
project, organized by ticket (Jira, Azure DevOps, ...).

Currently supports **Claude Code**. Codex and Antigravity support is planned.

## Skills

| Skill | What it does |
|---|---|
| [`jira-ticket-workbench`](skills/jira-ticket-workbench/jira-ticket-workbench-README.md) | Tracks Jira issues and their linked Confluence pages in `jira-workbench/`. Needs the Atlassian Rovo MCP connector. |
| [`ado-ticket-workbench`](skills/ado-ticket-workbench/ado-ticket-workbench-README.md) | Tracks Azure DevOps work items in `ticket-workbench/`. Needs an Azure DevOps MCP server. |

Both skills keep per-ticket plans, notes, route maps and context packs so a later session can pick up where the last
one stopped, and ship a PreCompact hook (requires Node.js) that saves ticket context before Claude compacts the conversation.

## Install

### Option A: Claude Code plugin

In Claude Code:

```text
/plugin marketplace add dngioidev/workbench-skills
/plugin install workbench@workbench-skills
```

Plugin skills are namespaced, e.g. `/workbench:jira-ticket-workbench`. Update with
`/plugin marketplace update workbench-skills`.

### Option B: Install script (global or project)

- **Global** installs to `~/.claude/skills/` — available in every project.
- **Project** installs to `<project>/.claude/skills/` — commit it to share with your team.

Script-installed skills are not namespaced, e.g. `/jira-ticket-workbench`.

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
./install.sh --scope project --path ~/my-app
```

On Windows (the default execution policy blocks running `.ps1` files directly):

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Scope project -Path D:\my-app
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
4. Run the tests: `bash tests/test-install.sh`, `powershell -ExecutionPolicy Bypass -File tests/test-install.ps1`,
   and `node tests/test-hooks.js` (if the skill ships a hook).

## License

[MIT](LICENSE)

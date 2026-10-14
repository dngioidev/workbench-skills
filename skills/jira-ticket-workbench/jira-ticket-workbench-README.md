# Jira Ticket Workbench — User Guide

A Claude skill for working with Jira issues (and the Confluence pages that document them) inside your repository. It maintains a local `jira-workbench/` folder as reusable working memory so Claude can plan, implement, review, debug, and close tickets with full context — even across separate chat sessions.

This is a sibling of [`ado-ticket-workbench`](../ado-ticket-workbench/), adapted from Azure DevOps to Jira + Confluence via the **Atlassian Rovo** MCP connector. If you've used the ADO version, the workflow verbs and file layout will feel identical — the differences are in how tickets are identified (`PROJ-123`, not a bare number), how "done-ness" and mode selection are decided (Jira has no universal effort field or fixed status list), and the addition of Confluence as a first-class documentation source.

---

## What It Does

- Reads Jira issues (and linked Confluence pages) via the Atlassian Rovo MCP and creates local context files
- Chooses the right level of documentation for each ticket (minimal to full)
- Keeps local notes safe when syncing — your notes are never overwritten
- Gives every future Claude session a clear starting point via route maps and context packs
- Tracks acceptance criteria, PRs, test evidence, and bug investigations
- Surfaces the Confluence documentation actually relevant to a ticket, instead of leaving you to go find it
- Maintains a searchable index and machine-readable manifest of all tracked tickets

---

## Installation

Install from [workbench-skills](https://github.com/dngioidev/workbench-skills#install) — either as the `workbench` Claude Code plugin or with the install script (global `~/.claude/skills/` or per-project `.claude/skills/`). Once installed, Claude will automatically use it whenever you work with Jira issues on an Atlassian Rovo-connected site.

You also need the Atlassian Rovo MCP connector connected to Claude (Jira + Confluence scopes). If it's not connected, Claude will work from existing local files and tell you clearly. Note that an Atlassian OAuth connection is scoped to specific sites — if your ticket's site isn't authorized yet, Claude will tell you it needs to be added (via the connector's own reconnect/site-selection flow), rather than silently querying the wrong site.

### First-time setup for a new project

Before the first real sync, create `jira-workbench/config.yml` from `templates/config-template.yml` and fill in:

- `jira.cloudId` — the site hostname or cloud ID (e.g. `your-company.atlassian.net`)
- `jira.projectKey` — the Jira project this workspace tracks (e.g. `PROJ`)
- `confluence.spaceKey` — the Confluence space documenting this project (e.g. `DOCS`)

Leave `jira.storyPointsFieldId` as `null` until you've looked it up for this site (see `references/documentation-modes.md`) — Claude will fall back to type-based mode selection until then, which works fine on its own.

---

## Where Files Are Stored

Everything lives in an `jira-workbench/` folder inside your repository:

```
jira-workbench/
  config.yml          workspace configuration
  index.md            human-readable list of all tracked tickets
  manifest.json        machine-readable ticket registry

  story/
    index.md
    PROJ-123/
      PROJ-123_description.md
      PROJ-123_plan.md
      PROJ-123_route_map.md
      PROJ-123_sync_log.md

  bug/
    PROJ-87/
      PROJ-87_description.md
      PROJ-87_repro_notes.md
      PROJ-87_fix_analysis.md
      ...

  epic/
    PROJ-10/
      PROJ-10_overview.md
      PROJ-10_relationship_map.md
      ...
```

Note the ticket key is always the **full Jira key** (`PROJ-123`), not a bare number — Jira keys already encode the project, so there's no ambiguity even if you track more than one project's tickets in the same workspace.

Files are created on demand — only what is needed for the current task is created. You can commit `jira-workbench/` to Git; the files are designed to diff cleanly.

---

## Basic Commands

These are plain-language phrases you type to Claude. No special syntax required.

### Reading a ticket

```
read ticket PROJ-123
```

Claude reads the ticket from Jira, discovers any linked Confluence pages, creates a description file (with a Related Documentation section), sets up a route map and sync log, and reports the file paths it created.

---

### Planning implementation

```
plan ticket PROJ-123
```

Claude ensures the ticket description is fresh, picks a documentation mode based on issue type and complexity, and creates an implementation plan. For larger tickets it also creates an acceptance criteria trace and a development context file.

---

### Continuing work from a previous session

```
continue ticket PROJ-123
```

Claude reads the route map, context pack, description, and plan, then summarises where things are and states the next best action. No files are recreated unnecessarily.

---

### Compacting context before ending a session

```
compact ticket PROJ-123
```

or

```
compact this ticket context
```

Claude updates the route map and creates or refreshes a context pack — a tight summary of the current goal, decisions made, current state, and next step. Use this before ending a session so the next session starts fast.

---

### Reviewing a pull request

```
review PR for ticket PROJ-123
```

Claude reads the ticket context first, then creates a PR review file with findings, required changes, suggestions, risks, and a final review status. Since the Jira MCP tools here don't expose linked PRs, give Claude the PR URL/number directly if you have one.

---

### Resolving PR or ticket comments

```
resolve comments for ticket PROJ-123
```

Claude creates a comment resolution plan listing each comment, the planned fix, files to update, validation steps, and draft responses. This is for **code-review comments** on a PR — to reply to the ticket's own Jira discussion thread, just ask Claude to post a Jira comment directly.

---

### Debugging a bug

```
debug bug PROJ-87
```

Claude uses the investigation workflow and creates reproduction notes, a fix analysis (root cause + fix options), a debug log, and test evidence.

---

### Updating an epic overview

```
update epic PROJ-10
```

Claude reads the epic and all its active children from Jira (trying both the `parent` field and the classic Epic Link field, whichever this site uses), refreshes stale child descriptions, and updates the overview and relationship map.

---

### Closing a ticket

```
close ticket PROJ-123
```

Claude creates a final summary covering what changed, files modified, acceptance criteria completed, test evidence, and known follow-ups. No files are deleted.

---

### Linking a Confluence page manually

```
note confluence page https://your-company.atlassian.net/wiki/spaces/DOCS/pages/100002 against ticket PROJ-123
```

Claude attaches the page to the ticket's Related Documentation section and remembers the link for future syncs — useful for docs that don't mention the ticket key by name and so can't be auto-discovered.

---

## Documentation Modes

Claude picks the right mode automatically. You can override it if needed.

| Mode | When It's Used | Default Files Created |
|---|---|---|
| **QuickTrack** | Task, Subtask, or a simple Story | `description`, `route_map`, `sync_log` |
| **DeliveryTrack** | Story/Task that's clearly complex, multi-session, or (if configured) has story points ≥5 | `description`, `plan`, `ac_trace`, `dev_context`, `route_map`, `context_pack`, `sync_log` |
| **InvestigationTrack** | Bug with unknown root cause | `description`, `repro_notes`, `fix_analysis`, `debug_log`, `test_evidence`, `route_map`, `sync_log` |
| **OverviewTrack** | Epic | `description`, `overview`, `relationship_map`, `route_map`, `context_pack`, `sync_log` |

QuickTrack starts minimal but can grow. Adding a plan or test evidence file to a QuickTrack ticket does not automatically upgrade it to DeliveryTrack. Claude only upgrades when the work is clearly multi-step, high-risk, or likely to continue across multiple sessions.

Unlike Azure DevOps, Jira has no universal numeric "effort" field — mode selection is **type-first** (Epic → OverviewTrack, Bug with unknown cause → InvestigationTrack, Task/Subtask → QuickTrack by default), refined by story points only once you've told `config.yml` the actual custom field ID for this site.

To explicitly request a full plan on a small ticket:

```
plan ticket PROJ-123 with full delivery track
```

---

## All File Types

Each file is named `{ticketId}_{purpose}.md`. Here is what every purpose is for:

| File Purpose | What It Contains |
|---|---|
| `description` | Ticket metadata, description, acceptance criteria, related Confluence docs, related tickets, and local notes |
| `plan` | Goal, impacted areas, step-by-step implementation plan, risks, test plan, rollback |
| `route_map` | Session handoff guide — current goal, status, key decisions, next step |
| `context_pack` | Compact continuation summary for starting a new Claude session |
| `ac_trace` | Acceptance criteria mapped to implementation areas and test evidence |
| `dev_context` | Branches, PRs, key files, useful commands, environment notes |
| `working_notes` | Decisions, assumptions, open questions, useful findings |
| `debug_log` | Observations, hypotheses, experiments, and findings during debugging |
| `repro_notes` | Bug reproduction steps, environment, frequency |
| `fix_analysis` | Root cause, fix options, selected fix, validation plan |
| `pr_review` | PR findings, required changes, suggestions, risks, final review status |
| `code_review` | Deep code-level review — correctness, security, performance, maintainability |
| `comment_resolution_plan` | Comments to resolve, planned fixes, response drafts |
| `test_evidence` | Automated test results, manual checks, regression checks |
| `manual_verification` | Structured QA walkthrough with step-by-step results and sign-off |
| `overview` | Epic overview — child ticket progress, blockers, risks, next steps |
| `relationship_map` | Parent-child dependency and sequencing map |
| `sync_log` | Append-only history of every Jira sync event |
| `final_summary` | Closure record — what changed, AC completed, test evidence, follow-ups |

---

## Your Notes Are Always Safe

Every file has a managed section (updated from Jira/Confluence on sync) and a local section (never touched):

```markdown
<!-- JIRA_MANAGED_START -->
This content is refreshed from Jira (and linked Confluence pages) when the ticket is newer.
<!-- JIRA_MANAGED_END -->

<!-- LOCAL_NOTES_START -->
Your notes here. Claude never overwrites this.
<!-- LOCAL_NOTES_END -->
```

You can write freely in any `Local Notes`, `Working Notes`, `Decisions`, or similar section. When you ask Claude to refresh a ticket, only the Jira/Confluence data is updated.

---

## Stale Context Warning

If a ticket's local context is more than 3 days old (configurable in `jira-workbench/config.yml`), Claude will warn you before planning, reviewing, or closing:

> "Local context may be stale (last synced: 2026-09-13). Consider refreshing from Jira first."

You can proceed without refreshing — Claude will work from what it has and say so.

---

## Customising the Workspace

Edit `jira-workbench/config.yml` to change defaults:

```yaml
jira:
  cloudId: your-company.atlassian.net
  projectKey: PROJ
  storyPointsFieldId: null   # set once you've found the real customfield_XXXXX id

confluence:
  spaceKey: DOCS

# How many days before a ticket is considered stale
refreshPolicy:
  staleAfterDays: 3          # change to 7 for less frequent warnings

# Section headers Claude will never overwrite
preserveSections:
  - Local Notes
  - Working Notes
  - Decisions
  # Add your own headings here
```

---

## Tips

**Starting a new session on an existing ticket:**
Always say `continue ticket {id}` first. Claude reads the route map and context pack, so it arrives oriented rather than starting from scratch.

**Before a long implementation session:**
Say `plan ticket {id}`. Claude creates a step-by-step plan you can work through together, with risks and edge cases called out upfront.

**Before ending a session:**
Say `compact ticket {id}`. This takes 30 seconds and makes the next session significantly faster.

**For a bug where you're not sure what's wrong:**
Say `debug bug {id}`. Claude uses the investigation track and builds a debug log where you can record observations and experiments as you go.

**For epics with many children:**
Say `update epic {id}` periodically. Claude checks every active child against Jira, refreshes stale descriptions, and gives you a current overview with blockers and risks highlighted.

**When a ticket's real context lives in a design doc, not the Jira description:**
Say `note confluence page {url} against ticket {id}` once — Claude will keep surfacing it on every future sync.

---

## Pre-Compact Hook

The skill includes a **pre-compact hook** that runs automatically every time Claude Code is about to compact the conversation context — whether triggered manually or automatically when the context window fills up.

### What it does

The hook checks `jira-workbench/manifest.json` for active tickets (any ticket whose `statusCategory` isn't `done`) and takes one of two actions:

**If any active ticket is missing a route map on disk:**

Compaction is **blocked**. Claude sees a message like:

> Jira Ticket Workbench: Route map missing for active ticket(s): story PROJ-123. Run the following before compaction: `compact ticket PROJ-123`

Claude will then run the compact command, write the route map and context pack to disk, and compaction can proceed normally. Nothing is lost.

**If all active tickets have route maps on disk:**

A snapshot file is written to `jira-workbench/pre-compact-snapshot.md` and compaction proceeds. You'll see a status message:

> Jira Ticket Workbench: Context snapshot saved for 2 active ticket(s) (story PROJ-123, bug PROJ-87). → jira-workbench/pre-compact-snapshot.md

### The snapshot file

`pre-compact-snapshot.md` is a lightweight recovery file that survives compaction. For each active ticket it records:

- Status (and status category), mode, last synced date
- Current goal, current status, last completed step, next recommended step (extracted from the route map)
- Path to the route map and context pack

After compaction, you can read this file to immediately know which tickets were in progress and what the next step was for each one.

### Resuming after compaction

After a compaction, run:

```
continue ticket PROJ-123
```

Claude reads the route map and context pack and resumes exactly where you left off — no need to re-explain anything.

### No installation needed

The hook script lives inside the skill package at `jira-ticket-workbench/hooks/pre-compact.js`. The skill frontmatter finds it automatically whether the skill is installed per-project (`.claude/skills/`), globally (`~/.claude/skills/`), or as a plugin. Like all skill hooks, it is registered once the skill has been used in the session. Node.js is the only requirement, and it is always available wherever Claude Code runs.

---

## Supported Jira Issue Types

Jira issue types are configured per project, not fixed org-wide — the table below is the common convention this skill normalizes to; see `references/ticket-type-normalization.md` for the fallback lookup when a project uses something else.

| Jira Issue Type | Stored In |
|---|---|
| Epic | `jira-workbench/epic/` |
| Story | `jira-workbench/story/` |
| Task | `jira-workbench/task/` |
| Subtask | `jira-workbench/subtask/` |
| Bug | `jira-workbench/bug/` |

---

## Important Principles

- **Jira is the source of truth for issue fields; Confluence is the source of truth for prose docs.** Claude never invents either.
- **`jira-workbench/` is working memory.** It is context to help Claude and developers — not authoritative records.
- **Files are never deleted automatically.** Even when a ticket is closed, all files stay.
- **Syncing preserves your notes.** Only Jira/Confluence-managed sections are updated on a refresh.
- **Modes never downgrade automatically.** Once a ticket is in DeliveryTrack, it stays there unless you say otherwise.
- **A `cloudId` is never guessed.** A wrong one silently queries the wrong company's Jira site.

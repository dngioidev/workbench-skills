# ADO Ticket Workbench — User Guide

A Claude skill for working with Azure DevOps tickets inside your repository. It maintains a local `ticket-workbench/` folder as reusable working memory so Claude can plan, implement, review, debug, and close tickets with full context — even across separate chat sessions.

---

## What It Does

- Reads Azure DevOps tickets via MCP and creates local context files
- Chooses the right level of documentation for each ticket (minimal to full)
- Keeps local notes safe when syncing — your notes are never overwritten
- Gives every future Claude session a clear starting point via route maps and context packs
- Tracks acceptance criteria, PRs, test evidence, and bug investigations
- Maintains a searchable index and machine-readable manifest of all tracked tickets

---

## Installation

Install from [workbench-skills](https://github.com/dngioidev/workbench-skills#install) — either as the `workbench` Claude Code plugin or with the install script (global `~/.claude/skills/` or per-project `.claude/skills/`). Once installed, Claude will automatically use the skill whenever you work with Azure DevOps tickets.

You also need an Azure DevOps MCP server connected to Claude. The skill uses it to read work items, child tickets, comments, and history. If the MCP server is not connected, Claude will work from existing local files and tell you clearly.

---

## Where Files Are Stored

Everything lives in a `ticket-workbench/` folder inside your repository:

```
ticket-workbench/
  config.yml          workspace configuration
  index.md            human-readable list of all tracked tickets
  manifest.json       machine-readable ticket registry

  pbi/
    index.md
    12345/
      12345_description.md
      12345_plan.md
      12345_route_map.md
      12345_sync_log.md

  bug/
    67890/
      67890_description.md
      67890_repro_notes.md
      67890_fix_analysis.md
      ...

  epic/
    10000/
      10000_overview.md
      10000_relationship_map.md
      ...
```

Files are created on demand — only what is needed for the current task is created. You can commit `ticket-workbench/` to Git; the files are designed to diff cleanly.

---

## Basic Commands

These are plain-language phrases you type to Claude. No special syntax required.

### Reading a ticket

```
read ticket 12345
```

Claude reads the ticket from Azure DevOps, creates a description file, sets up a route map and sync log, and reports the file paths it created.

---

### Planning implementation

```
plan ticket 12345
```

Claude ensures the ticket description is fresh, picks a documentation mode based on effort, and creates an implementation plan. For larger tickets it also creates an acceptance criteria trace and a development context file.

---

### Continuing work from a previous session

```
continue ticket 12345
```

Claude reads the route map, context pack, description, and plan, then summarises where things are and states the next best action. No files are recreated unnecessarily.

---

### Compacting context before ending a session

```
compact ticket 12345
```

or

```
compact this ticket context
```

Claude updates the route map and creates or refreshes a context pack — a tight summary of the current goal, decisions made, current state, and next step. Use this before ending a session so the next session starts fast.

---

### Reviewing a pull request

```
review PR for ticket 12345
```

Claude reads the ticket context first, then creates a PR review file with findings, required changes, suggestions, risks, and a final review status.

---

### Resolving PR or ticket comments

```
resolve comments for ticket 12345
```

Claude creates a comment resolution plan listing each comment, the planned fix, files to update, validation steps, and draft responses.

---

### Debugging a bug

```
debug bug 67890
```

Claude uses the investigation workflow and creates reproduction notes, a fix analysis (root cause + fix options), a debug log, and test evidence.

---

### Updating an epic or feature overview

```
update epic 10000
```

or

```
update feature 20000
```

Claude reads the parent and all active children from Azure DevOps, refreshes stale child descriptions, and updates the overview and relationship map.

---

### Closing a ticket

```
close ticket 12345
```

Claude creates a final summary covering what changed, files modified, acceptance criteria completed, test evidence, and known follow-ups. No files are deleted.

---

## Documentation Modes

Claude picks the right mode automatically. You can override it if needed.

| Mode | When It's Used | Default Files Created |
|---|---|---|
| **QuickTrack** | Effort 1, 2, or 3 | `description`, `route_map`, `sync_log` |
| **DeliveryTrack** | Effort 5 or 8, or clearly complex work | `description`, `plan`, `ac_trace`, `dev_context`, `route_map`, `context_pack`, `sync_log` |
| **InvestigationTrack** | Bug with unknown root cause | `description`, `repro_notes`, `fix_analysis`, `debug_log`, `test_evidence`, `route_map`, `sync_log` |
| **OverviewTrack** | Epic or Feature | `description`, `overview`, `relationship_map`, `route_map`, `context_pack`, `sync_log` |

QuickTrack starts minimal but can grow. Adding a plan or test evidence file to a QuickTrack ticket does not automatically upgrade it to DeliveryTrack. Claude only upgrades when the work is clearly multi-step, high-risk, or likely to continue across multiple sessions.

To explicitly request a full plan on a small ticket:

```
plan ticket 12345 with full delivery track
```

---

## All File Types

Each file is named `{ticketId}_{purpose}.md`. Here is what every purpose is for:

| File Purpose | What It Contains |
|---|---|
| `description` | Ticket metadata, description, acceptance criteria, related tickets, and local notes |
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
| `overview` | Epic/feature overview — child ticket progress, blockers, risks, next steps |
| `relationship_map` | Parent-child dependency and sequencing map |
| `sync_log` | Append-only history of every Azure DevOps sync event |
| `final_summary` | Closure record — what changed, AC completed, test evidence, follow-ups |

---

## Your Notes Are Always Safe

Every file has a managed section (updated from Azure DevOps on sync) and a local section (never touched):

```markdown
<!-- ADO_MANAGED_START -->
This content is refreshed from Azure DevOps when the ticket is newer.
<!-- ADO_MANAGED_END -->

<!-- LOCAL_NOTES_START -->
Your notes here. Claude never overwrites this.
<!-- LOCAL_NOTES_END -->
```

You can write freely in any `Local Notes`, `Working Notes`, `Decisions`, or similar section. When you ask Claude to refresh a ticket, only the Azure DevOps data is updated.

---

## Stale Context Warning

If a ticket's local context is more than 3 days old (configurable in `ticket-workbench/config.yml`), Claude will warn you before planning, reviewing, or closing:

> "Local context may be stale (last synced: 2026-05-26). Consider refreshing from Azure DevOps first."

You can proceed without refreshing — Claude will work from what it has and say so.

---

## Customising the Workspace

Edit `ticket-workbench/config.yml` to change defaults:

```yaml
# How many days before a ticket is considered stale
refreshPolicy:
  staleAfterDays: 3          # change to 7 for less frequent warnings

# Statuses treated as "done" (no auto-refresh)
doneStatuses:
  - Done
  - Closed
  - Removed
  - Resolved

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
Say `update epic {id}` periodically. Claude checks every active child against Azure DevOps, refreshes stale descriptions, and gives you a current overview with blockers and risks highlighted.

---

## Pre-Compact Hook

The skill includes a **pre-compact hook** that runs automatically every time Claude Code is about to compact the conversation context — whether triggered manually or automatically when the context window fills up.

### What it does

The hook checks `ticket-workbench/manifest.json` for active tickets (any ticket not in Done, Closed, Removed, or Resolved status) and takes one of two actions:

**If any active ticket is missing a route map on disk:**

Compaction is **blocked**. Claude sees a message like:

> ADO Ticket Workbench: Route map missing for active ticket(s): pbi 12345. Run the following before compaction: `compact ticket 12345`

Claude will then run the compact command, write the route map and context pack to disk, and compaction can proceed normally. Nothing is lost.

**If all active tickets have route maps on disk:**

A snapshot file is written to `ticket-workbench/pre-compact-snapshot.md` and compaction proceeds. You'll see a status message:

> ADO Ticket Workbench: Context snapshot saved for 2 active ticket(s) (pbi 12345, bug 67890). → ticket-workbench/pre-compact-snapshot.md

### The snapshot file

`pre-compact-snapshot.md` is a lightweight recovery file that survives compaction. For each active ticket it records:

- Status, mode, effort, last synced date
- Current goal, current status, last completed step, next recommended step (extracted from the route map)
- Path to the route map and context pack

After compaction, you can read this file to immediately know which tickets were in progress and what the next step was for each one.

### Resuming after compaction

After a compaction, run:

```
continue ticket 12345
```

Claude reads the route map and context pack and resumes exactly where you left off — no need to re-explain anything.

### No installation needed

The hook script lives inside the skill package at `ado-ticket-workbench/hooks/pre-compact.js`. The skill frontmatter finds it automatically whether the skill is installed per-project (`.claude/skills/`), globally (`~/.claude/skills/`), or as a plugin. Like all skill hooks, it is registered once the skill has been used in the session. Node.js is the only requirement, and it is always available wherever Claude Code runs.

---

## Supported Azure DevOps Work Item Types

| Azure DevOps Type | Stored In |
|---|---|
| Epic | `ticket-workbench/epic/` |
| Feature | `ticket-workbench/feature/` |
| Product Backlog Item | `ticket-workbench/pbi/` |
| User Story | `ticket-workbench/pbi/` |
| Bug | `ticket-workbench/bug/` |
| Spike | `ticket-workbench/spike/` |

---

## Important Principles

- **Azure DevOps is the source of truth.** Claude never invents ticket field values.
- **`ticket-workbench/` is working memory.** It is context to help Claude and developers — not authoritative records.
- **Files are never deleted automatically.** Even when a ticket is closed, all files stay.
- **Syncing preserves your notes.** Only Azure DevOps-managed sections are updated on a refresh.
- **Modes never downgrade automatically.** Once a ticket is in DeliveryTrack, it stays there unless you say otherwise.

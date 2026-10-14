---
name: jira-ticket-workbench
description: Manages Jira ticket work (and its linked Confluence documentation) inside a repository using a local documentation workspace (jira-workbench/). Activate this skill when asked to read, summarize, plan, continue, debug, review PRs, resolve comments, close, or track Jira issues — epics, stories, tasks, subtasks, or bugs — on any Atlassian Rovo-connected site. Trigger on any mention of a Jira issue key (the PROJECT-123 pattern, e.g. PROJ-123), a Jira board or backlog, sprint/story-point planning, acceptance-criteria tracking, QA handoff, context compaction, epic/story overviews, linking or finding Confluence documentation for a ticket, or continuation of a previous ticket session. Always use this skill for multi-step ticket workflows even if not explicitly requested.
license: MIT
metadata:
  author: dngioidev
  version: 0.1.0
  repository: https://github.com/dngioidev/workbench-skills
hooks:
  PreCompact:
    - hooks:
        - type: command
          command: "node"
          # Finds the skill in a project, plugin, or global (~/.claude/skills) install.
          args: ["-e", "const fs=require('fs'),p=require('path'),e=process.env,s=p.join('jira-ticket-workbench','hooks','pre-compact.js');const f=[e.CLAUDE_PROJECT_DIR&&p.join(e.CLAUDE_PROJECT_DIR,'.claude','skills',s),e.CLAUDE_PLUGIN_ROOT&&p.join(e.CLAUDE_PLUGIN_ROOT,'skills',s),p.join(require('os').homedir(),'.claude','skills',s)].find(x=>x&&fs.existsSync(x));if(f)require(f);"]
          statusMessage: "Preserving ticket context before compaction..."
---

# Jira Ticket Workbench

Helps Claude work with Jira issues (and the Confluence pages that document them) by maintaining a local `jira-workbench/` folder as reusable working memory inside the target repository.

> **Jira is the source of truth for issue fields, and Confluence is the source of truth for prose documentation. `jira-workbench/` is working context — not authoritative.**

Both sources are reached through the **Atlassian Rovo** MCP connector. Its tool names are long and often deferred — if a call fails with a schema/validation error, run `ToolSearch` first, e.g.:

```
ToolSearch: select:mcp__<rovo-id>__searchJiraIssuesUsingJql,mcp__<rovo-id>__getJiraIssue,mcp__<rovo-id>__getConfluencePage
```

(the `<rovo-id>` segment is whatever this session's Atlassian Rovo connector is prefixed with — check the current tool list rather than assuming a fixed id).

---

## Reference Files

Load only what you need for the current task:

| Task | Read |
|---|---|
| Choosing or switching documentation mode | `references/documentation-modes.md` |
| Syncing from Jira via Atlassian Rovo MCP | `references/sync-rules.md` |
| Creating, updating, or preserving files | `references/file-lifecycle.md` |
| Mapping a Jira issue type to a folder name | `references/ticket-type-normalization.md` |
| Finding, linking, or summarizing Confluence pages for a ticket | `references/confluence-integration.md` |
| Creating any new workspace file | See **Template Lookup** section below |

---

## Site Configuration (read this before the first sync)

Unlike Azure DevOps, a Jira MCP connection can span multiple sites and projects. Before doing real work, make sure `jira-workbench/config.yml` has been created (from `templates/config-template.yml`) with this project's actual values:

- `cloudId` — the Atlassian site's cloud ID or hostname (e.g. `your-company.atlassian.net`)
- `projectKey` — the Jira project key this workspace tracks (e.g. `PROJ`)
- `confluenceSpaceKey` — the Confluence space documenting this project (e.g. `DOCS`)
- `storyPointsFieldId` — optional; a story-points custom field ID (e.g. `customfield_10016`) *if* one has been identified for this site (see `references/documentation-modes.md` for how to find it once)

If asked to work with a ticket key whose project prefix doesn't match `config.yml`, or before `config.yml` exists at all, ask which site/project/space to use rather than guessing — a wrong `cloudId` silently queries the wrong company's Jira.

---

## Workspace Structure

Create inside the target repository on demand. Do not pre-create all folders.

```text
jira-workbench/
  config.yml              ← workspace config (create on first use)
  index.md                ← human-readable index of all tracked tickets
  manifest.json            ← machine-readable ticket registry

  epic/index.md
  epic/{ticketId}/

  story/index.md
  story/{ticketId}/

  task/index.md
  task/{ticketId}/

  subtask/index.md
  subtask/{ticketId}/

  bug/index.md
  bug/{ticketId}/
```

`{ticketId}` is always the full Jira issue key, e.g. `PROJ-123` — never a bare number.

---

## File Naming

```
jira-workbench/{ticketType}/{ticketId}/{ticketId}_{filePurpose}.md
```

**Examples:**
- `jira-workbench/story/PROJ-123/PROJ-123_description.md`
- `jira-workbench/story/PROJ-123/PROJ-123_plan.md`
- `jira-workbench/bug/PROJ-87/PROJ-87_fix_analysis.md`
- `jira-workbench/epic/PROJ-10/PROJ-10_overview.md`

**Supported purposes:**
`description` · `overview` · `relationship_map` · `plan` · `ac_trace` · `dev_context` · `working_notes` · `debug_log` · `repro_notes` · `fix_analysis` · `pr_review` · `code_review` · `comment_resolution_plan` · `test_evidence` · `manual_verification` · `route_map` · `context_pack` · `sync_log` · `final_summary`

These purposes are the same as a generic ticket-tracking workflow — none of them are ADO- or Jira-specific, so the taxonomy carries over unchanged.

---

## Template Lookup

Use this table to find the exact template filename for each file purpose. Template filenames use hyphens; file purposes use underscores — they do not map 1:1 by name.

| Purpose | Template file |
|---|---|
| `description` | `templates/description-template.md` |
| `overview` | `templates/overview-template.md` |
| `relationship_map` | `templates/relationship-map-template.md` |
| `plan` | `templates/plan-template.md` |
| `ac_trace` | `templates/ac-trace-template.md` |
| `dev_context` | `templates/dev-context-template.md` |
| `working_notes` | `templates/working-notes-template.md` |
| `debug_log` | `templates/debug-log-template.md` |
| `repro_notes` | `templates/repro-notes-template.md` |
| `fix_analysis` | `templates/fix-analysis-template.md` |
| `pr_review` | `templates/pr-review-template.md` |
| `code_review` | `templates/code-review-template.md` |
| `comment_resolution_plan` | `templates/comment-resolution-template.md` |
| `test_evidence` | `templates/test-evidence-template.md` |
| `manual_verification` | `templates/manual-verification-template.md` |
| `route_map` | `templates/route-map-template.md` |
| `context_pack` | `templates/context-pack-template.md` |
| `sync_log` | `templates/sync-log-template.md` |
| `final_summary` | `templates/final-summary-template.md` |
| workspace config | `templates/config-template.yml` |

---

## Ticket Type Normalization (Quick Reference)

Jira issue types are configured per-project, not fixed org-wide like Azure DevOps — read `references/ticket-type-normalization.md` for the full lookup and fallback procedure. Quick version:

| Common Jira Issue Type | Folder |
|---|---|
| Epic | `epic` |
| Story | `story` |
| Task | `task` |
| Subtask / Sub-task | `subtask` |
| Bug | `bug` |

Unfamiliar type → look up the project's real scheme with `getJiraProjectIssueTypesMetadata` / `getJiraIssueTypeMetaWithFields` before guessing; fall back to `task` only if that lookup is inconclusive, and say so.

---

## Documentation Mode Selection (Quick Reference)

Read `references/documentation-modes.md` for full config and rules.

| Mode | Trigger | Default Files |
|---|---|---|
| **quickTrack** | Task/Subtask, or Story with no complexity signals | `description`, `route_map`, `sync_log` |
| **deliveryTrack** | Story/Task that's clearly complex, multi-session, or has story points ≥5 (when the field is configured) | `description`, `plan`, `ac_trace`, `dev_context`, `route_map`, `context_pack`, `sync_log` |
| **investigationTrack** | Bug with unknown root cause | `description`, `repro_notes`, `fix_analysis`, `debug_log`, `test_evidence`, `route_map`, `sync_log` |
| **overviewTrack** | Epic (or a Story acting as a parent with many subtasks) | `description`, `overview`, `relationship_map`, `route_map`, `context_pack`, `sync_log` |

**Critical rules:**
- Use the **smallest useful mode**.
- QuickTrack may use optional files when useful — adding one optional file does **not** mean upgrade to DeliveryTrack.
- Upgrade to DeliveryTrack **only** when complexity, risk, or multi-session continuation clearly justifies it.
- **Never downgrade** a ticket automatically.
- **Never delete** ticket files automatically.
- **Never overwrite** local or human-written sections.
- Jira rarely exposes a universal "effort" field the way Azure DevOps does — mode selection is **type-first**, refined by story points only when `config.yml` names the real custom field for this site.

---

## Frontmatter (All Ticket Files)

```yaml
---
ticketId: PROJ-123
ticketType: story
title: Add CSV export to the reports page
status: In Progress
documentationMode: quickTrack
source: jira
cloudId: 11111111-2222-4333-8444-555555555555
jiraUpdated: 2026-09-03T22:28:13.286+0700
lastSyncedFromJira: 2026-09-16T10:30:00+0700
generatedBy: claude
---
```

**Field notes:**
- `ticketType` — the **normalized** folder name (e.g. `story`, `bug`, `epic`). Always lowercase.
- `ticketTypeOriginal` — the **original Jira issue type** string, when it differs from the normalized name (rare, since normalization mostly preserves Jira's own vocabulary) or for unfamiliar/fallback types.
- `ticketTypeLabel` — the **human-readable display label** used in file headings. See label map in `references/ticket-type-normalization.md`.
- `cloudId` — which Atlassian site this ticket lives on; carry it in every file so a workspace can (in principle) track tickets across more than one site without ambiguity.

---

## Managed vs Local Sections

Use these markers in files that mix Jira/Confluence data with local notes:

```markdown
<!-- JIRA_MANAGED_START -->
Content updated from Jira (and linked Confluence pages) on each sync.
<!-- JIRA_MANAGED_END -->

<!-- LOCAL_NOTES_START -->
Human or AI working notes — never overwritten on sync.
<!-- LOCAL_NOTES_END -->
```

---

## Intent Behaviors

### "read ticket {id}"
1. Read the issue from Jira via Atlassian Rovo MCP (`getJiraIssue`)
2. Normalize type → folder (see `references/ticket-type-normalization.md`)
3. Detect complexity signal (issue type, subtask count, story points if configured) → choose documentation mode
4. Discover related Confluence pages (see `references/confluence-integration.md`) and summarize them into a **Related Documentation** section
5. Create/update: `description`, `route_map`, `sync_log`
6. Update `index.md`, `{type}/index.md`, `manifest.json`
7. Report all created/updated file paths

### "plan ticket {id}"
1. Ensure description is fresh — refresh from Jira if newer
2. Task/Subtask, simple Story → stay quickTrack unless work is clearly complex
3. Complex Story, or story points ≥5 when configured → use deliveryTrack
4. Create/update: `plan`; add `ac_trace`, `dev_context` if useful
5. If multi-session work is likely, update `route_map` and `context_pack`

### "continue ticket {id}"
1. Read: `manifest.json`, `route_map`, `context_pack`, `description`, `plan` (if present)
2. Summarize current status and context
3. State next best action
4. Do not recreate files that already exist

### "compact this ticket context" / "compact ticket {id}"
1. Update `route_map` — current state, key decisions, important files, next step
2. Create/update `context_pack`
3. Ensure future Claude session can continue from these two files

### "review PR for ticket {id}"
1. Read ticket context first
2. Create/update `pr_review` and/or `code_review`
3. Include findings, required changes, risks, test recommendations
4. Update `route_map` and `context_pack`

Note: Atlassian Rovo's Jira tools here don't expose the "Development" panel (linked PRs/commits/branches). If the user hasn't given a PR URL/number directly, ask for it rather than guessing at a linked PR.

### "resolve comments for ticket {id}"
1. Create/update `comment_resolution_plan`
2. Include: comments, planned fixes, files to update, validation steps, response drafts
3. Update `route_map` and `context_pack`

This is about **code-review comments** on a PR, not the ticket's own Jira discussion thread — don't conflate the two. If asked to reply to the *ticket's* Jira comments, use `addCommentToJiraIssue` directly instead.

### "debug bug {id}"
1. Use investigationTrack
2. Create/update: `repro_notes`, `fix_analysis`, `debug_log`, `test_evidence`, `route_map`

### "update epic {id}" / "update feature {id}"
1. Use overviewTrack
2. Read the epic and its children via `searchJiraIssuesUsingJql` with `"Epic Link" = {epicKey}` (classic/company-managed projects) or `parent = {epicKey}` (team-managed projects, or when hierarchy is on) — try the one appropriate to this site, or both
3. Refresh child description files where Jira is newer
4. Create/update: `overview`, `relationship_map`, `route_map`, `context_pack`
5. Update `index.md`, `{type}/index.md`, `manifest.json`

### "close ticket {id}"
1. Create/update `final_summary`
2. Update `manifest.json` and `index.md`
3. Mark final known state
4. Do **not** delete any files

### "note confluence page {url or title} against ticket {id}"
1. Resolve the page (via its URL/tiny-link ID, or by title search with `searchConfluenceUsingCql`)
2. Add it to the ticket's **Related Documentation** section and to `config.yml`'s manual link list (so future auto-discovery doesn't need to rediscover it)
3. Note in `sync_log` that this link was added manually, not auto-discovered

---

## Sync Behavior (Summary)

Full algorithm: `references/sync-rules.md`

1. Read the issue from Jira via Atlassian Rovo MCP — get key, type, title, status, priority, assignee, labels, components, parent/subtasks, `updated` timestamp
2. Compare Jira `updated` vs local `lastSyncedFromJira`
3. If Jira is newer → update the `JIRA_MANAGED` sections only
4. Preserve all local/human sections
5. Discover/refresh linked Confluence pages (see `references/confluence-integration.md`)
6. Append sync event to `sync_log`
7. Update `index.md`, `{type}/index.md`, `manifest.json`
8. Report all paths that changed

**If the Atlassian Rovo MCP is unavailable:** continue from local files, clearly state the ticket was not refreshed from Jira.

**Stale warning:** if `lastSyncedFromJira` is older than `staleAfterDays` (default: 3), warn before planning, reviewing, or closing.

---

## Manifest Entry Format

```json
{
  "ticketId": "PROJ-123",
  "type": "story",
  "title": "Add CSV export to the reports page",
  "status": "In Progress",
  "statusCategory": "indeterminate",
  "documentationMode": "quickTrack",
  "cloudId": "11111111-2222-4333-8444-555555555555",
  "folder": "jira-workbench/story/PROJ-123",
  "routeMap": "jira-workbench/story/PROJ-123/PROJ-123_route_map.md",
  "contextPack": "jira-workbench/story/PROJ-123/PROJ-123_context_pack.md",
  "lastSyncedFromJira": "2026-09-16T10:30:00+0700",
  "jiraUpdated": "2026-09-03T22:28:13.286+0700"
}
```

`statusCategory` is Jira's portable done-ness signal (`new` / `indeterminate` / `done`) — use it, not the raw `status` name, to decide whether a ticket is active (see `references/sync-rules.md`).

---

## Guardrails

- Jira is the source of truth for issue fields; Confluence is the source of truth for prose docs — never invent either
- `jira-workbench/` is working memory — useful context, not authoritative
- Never delete files unless explicitly asked
- Never overwrite local notes or human-written sections
- Prefer section-based updates over full file rewrites
- Append to sync history — do not replace it
- Warn if local context is stale (> `staleAfterDays`)
- If the Atlassian Rovo MCP is unavailable, continue from local files and say so clearly
- A `searchJiraIssuesUsingJql` call with full field objects on more than ~40-50 issues can exceed the tool's output limit — paginate (see `references/sync-rules.md`)
- Keep markdown deterministic and easy to diff in Git
- Always mention created/updated file paths after each operation
- Do not create unnecessary files
- Do not activate the full workflow for tiny one-off questions unless saving context is requested
- Document only what helps future Claude or developers continue the ticket faster
- Never guess a `cloudId` — a wrong one silently queries the wrong company's Jira site

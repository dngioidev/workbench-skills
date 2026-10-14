---
name: ado-ticket-workbench
description: Manages Azure DevOps ticket work inside a repository using a local documentation workspace (ticket-workbench/). Activate this skill when asked to read, summarize, plan, continue, debug, review PRs, resolve comments, close, or track Azure DevOps work items — epics, features, PBIs, user stories, bugs, or spikes. Trigger on any mention of Azure DevOps ticket IDs, ADO planning, acceptance criteria tracking, QA handoff, context compaction, epic/feature overviews, or continuation of previous ticket sessions. Always use this skill for multi-step ticket workflows even if not explicitly requested.
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
          args: ["-e", "const fs=require('fs'),p=require('path'),e=process.env,s=p.join('ado-ticket-workbench','hooks','pre-compact.js');const f=[e.CLAUDE_PROJECT_DIR&&p.join(e.CLAUDE_PROJECT_DIR,'.claude','skills',s),e.CLAUDE_PLUGIN_ROOT&&p.join(e.CLAUDE_PLUGIN_ROOT,'skills',s),p.join(require('os').homedir(),'.claude','skills',s)].find(x=>x&&fs.existsSync(x));if(f)require(f);"]
          statusMessage: "Preserving ticket context before compaction..."
---

# ADO Ticket Workbench

Helps Claude work with Azure DevOps tickets by maintaining a local `ticket-workbench/` folder as reusable working memory inside the target repository.

> **Azure DevOps is the source of truth for ticket fields. `ticket-workbench/` is working context — not authoritative.**

---

## Reference Files

Load only what you need for the current task:

| Task | Read |
|---|---|
| Choosing or switching documentation mode | `references/documentation-modes.md` |
| Syncing from Azure DevOps MCP | `references/sync-rules.md` |
| Creating, updating, or preserving files | `references/file-lifecycle.md` |
| Mapping work item type to folder name | `references/ticket-type-normalization.md` |
| Creating any new workspace file | See **Template Lookup** section below |

---

## Workspace Structure

Create inside the target repository on demand. Do not pre-create all folders.

```text
ticket-workbench/
  config.yml              ← workspace config (create on first use)
  index.md                ← human-readable index of all tracked tickets
  manifest.json           ← machine-readable ticket registry

  epic/index.md
  epic/{ticketId}/

  feature/index.md
  feature/{ticketId}/

  pbi/index.md
  pbi/{ticketId}/

  bug/index.md
  bug/{ticketId}/

  spike/index.md
  spike/{ticketId}/
```

---

## File Naming

```
ticket-workbench/{ticketType}/{ticketId}/{ticketId}_{filePurpose}.md
```

**Examples:**
- `ticket-workbench/pbi/12345/12345_description.md`
- `ticket-workbench/pbi/12345/12345_plan.md`
- `ticket-workbench/bug/67890/67890_fix_analysis.md`
- `ticket-workbench/epic/10000/10000_overview.md`

**Supported purposes:**
`description` · `overview` · `relationship_map` · `plan` · `ac_trace` · `dev_context` · `working_notes` · `debug_log` · `repro_notes` · `fix_analysis` · `pr_review` · `code_review` · `comment_resolution_plan` · `test_evidence` · `manual_verification` · `route_map` · `context_pack` · `sync_log` · `final_summary`

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

## Ticket Type Normalization

| Azure DevOps Type | Folder |
|---|---|
| Epic | `epic` |
| Feature | `feature` |
| Product Backlog Item | `pbi` |
| User Story | `pbi` |
| PBI | `pbi` |
| Bug | `bug` |
| Spike | `spike` |

Unknown type → infer from Azure DevOps, or fall back to `pbi` and state the uncertainty.
Full rules: `references/ticket-type-normalization.md`

---

## Documentation Mode Selection (Quick Reference)

Read `references/documentation-modes.md` for full config and rules.

| Mode | Trigger | Default Files |
|---|---|---|
| **quickTrack** | Effort 1–3 | `description`, `route_map`, `sync_log` |
| **deliveryTrack** | Effort 5–8 or clearly complex | `description`, `plan`, `ac_trace`, `dev_context`, `route_map`, `context_pack`, `sync_log` |
| **investigationTrack** | Bug with unknown root cause | `description`, `repro_notes`, `fix_analysis`, `debug_log`, `test_evidence`, `route_map`, `sync_log` |
| **overviewTrack** | Epic or Feature | `description`, `overview`, `relationship_map`, `route_map`, `context_pack`, `sync_log` |

**Critical rules:**
- Use the **smallest useful mode**.
- QuickTrack may use optional files when useful — adding one optional file does **not** mean upgrade to DeliveryTrack.
- Upgrade to DeliveryTrack **only** when complexity, risk, or multi-session continuation clearly justifies it.
- **Never downgrade** a ticket automatically.
- **Never delete** ticket files automatically.
- **Never overwrite** local or human-written sections.
- **Effort not set or unknown** → use quickTrack by default; note that effort is unset; offer to upgrade if work appears complex.
- **Non-standard effort** (0, 4, 6, 10, 13, 20, 40, or t-shirt sizes S/M/L/XL) → treat 0/S/M and unset as quickTrack; treat L/XL/13+ as deliveryTrack; treat 4/6/10 as judgment call based on ticket complexity.

---

## Frontmatter (All Ticket Files)

```yaml
---
ticketId: 12345
ticketType: pbi
title: Example title
status: In Progress
documentationMode: quickTrack
source: azure-devops
azureDevOpsChangedDate: 2026-05-29T09:55:00+07:00
lastSyncedFromAzureDevOps: 2026-05-29T10:30:00+07:00
generatedBy: claude
---
```

**Field notes:**
- `ticketType` — the **normalized** folder name (e.g. `pbi`, `bug`, `epic`). Always lowercase.
- `ticketTypeOriginal` — the **original Azure DevOps work item type** string (e.g. `Product Backlog Item`, `Bug`). Add this field when the original type differs from the normalized name, or for unknown types.
- `ticketTypeLabel` — the **human-readable display label** used in file headings. See label map in `references/ticket-type-normalization.md`.

---

## Managed vs Local Sections

Use these markers in files that mix Azure DevOps data with local notes:

```markdown
<!-- ADO_MANAGED_START -->
Content updated from Azure DevOps on each sync.
<!-- ADO_MANAGED_END -->

<!-- LOCAL_NOTES_START -->
Human or AI working notes — never overwritten on sync.
<!-- LOCAL_NOTES_END -->
```

---

## Intent Behaviors

### "read ticket {id}"
1. Read from Azure DevOps MCP
2. Normalize type → folder (see `references/ticket-type-normalization.md`)
3. Detect effort → choose documentation mode
4. Create/update: `description`, `route_map`, `sync_log`
5. Update `index.md`, `{type}/index.md`, `manifest.json`
6. Report all created/updated file paths

### "plan ticket {id}"
1. Ensure description is fresh — refresh from ADO if newer
2. Effort 1–3 → stay quickTrack unless work is clearly complex
3. Effort 5–8 → use deliveryTrack
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

### "resolve comments for ticket {id}"
1. Create/update `comment_resolution_plan`
2. Include: comments, planned fixes, files to update, validation steps, response drafts
3. Update `route_map` and `context_pack`

### "debug bug {id}"
1. Use investigationTrack
2. Create/update: `repro_notes`, `fix_analysis`, `debug_log`, `test_evidence`, `route_map`

### "update epic {id}" / "update feature {id}"
1. Use overviewTrack
2. Read parent + all active children from Azure DevOps MCP
3. Refresh child description files where ADO is newer
4. Create/update: `overview`, `relationship_map`, `route_map`, `context_pack`
5. Update `index.md`, `{type}/index.md`, `manifest.json`

### "close ticket {id}"
1. Create/update `final_summary`
2. Update `manifest.json` and `index.md`
3. Mark final known state
4. Do **not** delete any files

---

## Sync Behavior (Summary)

Full algorithm: `references/sync-rules.md`

1. Read ticket from Azure DevOps MCP — get ID, type, title, effort, status, changed date
2. Compare ADO `changedDate` vs local `lastSyncedFromAzureDevOps`
3. If ADO is newer → update `ADO_MANAGED` sections only
4. Preserve all local/human sections
5. Append sync event to `sync_log`
6. Update `index.md`, `{type}/index.md`, `manifest.json`
7. Report all paths that changed

**If ADO MCP is unavailable:** continue from local files, clearly state the ticket was not refreshed from Azure DevOps.

**Stale warning:** if `lastSyncedFromAzureDevOps` is older than `staleAfterDays` (default: 3), warn before planning, reviewing, or closing.

---

## Manifest Entry Format

```json
{
  "ticketId": "12345",
  "type": "pbi",
  "title": "Ticket title",
  "status": "In Progress",
  "documentationMode": "quickTrack",
  "effort": 3,
  "folder": "ticket-workbench/pbi/12345",
  "routeMap": "ticket-workbench/pbi/12345/12345_route_map.md",
  "contextPack": "ticket-workbench/pbi/12345/12345_context_pack.md",
  "lastSyncedFromAzureDevOps": "2026-05-29T10:30:00+07:00",
  "azureDevOpsChangedDate": "2026-05-29T09:55:00+07:00"
}
```

---

## Guardrails

- Azure DevOps is source of truth — never invent ticket field values
- `ticket-workbench/` is working memory — useful context, not authoritative
- Never delete files unless explicitly asked
- Never overwrite local notes or human-written sections
- Prefer section-based updates over full file rewrites
- Append to sync history — do not replace it
- Warn if local context is stale (> `staleAfterDays`)
- If ADO MCP unavailable, continue from local files and say so clearly
- Keep markdown deterministic and easy to diff in Git
- Always mention created/updated file paths after each operation
- Do not create unnecessary files
- Do not activate the full workflow for tiny one-off questions unless saving context is requested
- Document only what helps future Claude or developers continue the ticket faster

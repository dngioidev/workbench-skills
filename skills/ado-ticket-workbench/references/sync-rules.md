# Sync Rules

Full rules for syncing Azure DevOps ticket data into the local `ticket-workbench/` workspace.

---

## Azure DevOps MCP Assumptions

When reading from Azure DevOps MCP, Claude can access:

| Field | Notes |
|---|---|
| Ticket ID | Unique work item identifier |
| Work item type | Epic, Feature, Product Backlog Item, User Story, PBI, Bug, Spike |
| Title | Short title |
| Description | Full description HTML or markdown |
| Acceptance criteria | Defined criteria for completion |
| Effort / story points | Numeric estimate |
| Status | Current state |
| Assigned user | Assigned team member |
| Area path | Project area path |
| Iteration path | Sprint or iteration |
| Parent / children | Related work item hierarchy |
| Related work items | Links, dependencies |
| Comments | Thread of comments |
| History | Change history log |
| Changed date | Timestamp of last change in Azure DevOps |
| URL | Direct link to work item |

---

## Full Sync Algorithm

When reading a ticket from Azure DevOps MCP:

1. **Detect ticket ID** from the user's request or context.
2. **Read the work item** from Azure DevOps MCP — fetch all available fields.
3. **Normalize the work item type** to a folder name (see `ticket-type-normalization.md`).
4. **Detect effort** (story points). If unavailable, leave blank and proceed.
5. **Choose documentation mode** based on effort and type (see `documentation-modes.md`).
6. **Create the ticket folder** if it does not exist: `ticket-workbench/{type}/{ticketId}/`
7. **Create or update `{ticketId}_description.md`:**
   - Compare `azureDevOpsChangedDate` from ADO vs `lastSyncedFromAzureDevOps` in the local file's frontmatter.
   - If ADO `changedDate` is **newer**: update only the `ADO_MANAGED` sections. Do not touch `LOCAL_NOTES` sections.
   - If local file does not exist: create it fresh from the description template.
   - If ADO is **not newer** and local file exists: skip update (no changes needed).
8. **Preserve all local/human sections** — any section between `<!-- LOCAL_NOTES_START -->` and `<!-- LOCAL_NOTES_END -->`, or sections listed in `preserveSections` in `config.yml`.
9. **Append a sync event to `{ticketId}_sync_log.md`** — include timestamp, ADO changed date, files updated, and source status.
10. **Create or update `{ticketId}_route_map.md`** — update current status and last synced step.
11. **Update `ticket-workbench/index.md`** — upsert the row for this ticket.
12. **Update `ticket-workbench/{type}/index.md`** — upsert the row for this ticket.
13. **Update `ticket-workbench/manifest.json`** — upsert the entry for this ticket.
14. **Mention all created or updated file paths** at the end of the response.
15. **Report the documentation mode chosen** and any optional files that were also created.

---

## When Azure DevOps MCP Is Unavailable

If the Azure DevOps MCP is not reachable or returns an error:

- Continue from existing local files in `ticket-workbench/`.
- **Clearly state** at the start of the response: "Azure DevOps MCP is unavailable — continuing from local context. Ticket data may be stale."
- Do not attempt to invent or guess ticket field values.
- Proceed with the user's intent using available local context.
- Offer to retry the sync when ADO MCP becomes available.

---

## Stale Context Rule

If `lastSyncedFromAzureDevOps` in the local file's frontmatter is older than `staleAfterDays` (default: 3 days from `config.yml`):

- Warn before planning, reviewing, or closing a ticket: "Local context may be stale (last synced: {date}). Consider refreshing from Azure DevOps first."
- Do not block the user's request. Warn and proceed.

---

## Active vs Done Ticket Refresh Policy

| Ticket Status | Refresh Policy |
|---|---|
| Active (In Progress, New, Active, etc.) | Refresh if Azure DevOps `changedDate` is newer than local `lastSyncedFromAzureDevOps` |
| Done / Closed / Removed / Resolved | Refresh only when explicitly requested by the user |

Done statuses (from `config.yml`): `Done`, `Closed`, `Removed`, `Resolved`

---

## Section-Based Updates

When updating an existing file, prefer section-based updates over full rewrites:

1. Locate the `<!-- ADO_MANAGED_START -->` block.
2. Replace only the content between `ADO_MANAGED_START` and `ADO_MANAGED_END`.
3. Leave all other content unchanged.
4. Update the `lastSyncedFromAzureDevOps` value in frontmatter.
5. Do not reformat or restructure the rest of the file.

This keeps the file easy to diff in Git and preserves human edits.

---

## Sync Log Entry Format

Each sync appends a new entry to `{ticketId}_sync_log.md`. Format:

```markdown
## Sync — {ISO timestamp}

- **Source:** Azure DevOps MCP
- **ADO Changed Date:** {azureDevOpsChangedDate}
- **ADO Status:** {status}
- **Files Updated:** {comma-separated list}
- **Documentation Mode:** {mode}
- **Notes:** {any relevant notes, e.g. "ADO was newer — description refreshed"}
```

If ADO MCP was unavailable, log it:

```markdown
## Sync — {ISO timestamp}

- **Source:** Local files only (ADO MCP unavailable)
- **Files Updated:** none
- **Notes:** ADO MCP unreachable — continued from local context
```

---

## Index Update Format

### ticket-workbench/index.md

Human-readable table of all tracked tickets. Upsert the row for the current ticket.

```markdown
| Ticket ID | Type | Title | Status | Mode | Effort | Last Synced |
|---|---|---|---|---|---|---|
| 12345 | pbi | Example title | In Progress | quickTrack | 3 | 2026-05-29 |
```

### ticket-workbench/{type}/index.md

Same format, scoped to that ticket type.

---

## Manifest Update Format

`ticket-workbench/manifest.json` is a JSON array. Upsert by `ticketId`.

```json
[
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
]
```

Set `contextPack` to `null` if no context pack file exists yet.

---

## Epic and Feature Child Sync

When updating an epic or feature overview:

1. Read the parent work item from Azure DevOps MCP.
2. Read all child tickets.
3. For each child that is **not** in a done status, check the latest `changedDate`.
4. Refresh local `{childId}_description.md` if ADO is newer.
5. Summarize child progress into the parent `{ticketId}_overview.md`.
6. Update `{ticketId}_relationship_map.md`.
7. Update `route_map`, `context_pack`, indexes, and manifest.

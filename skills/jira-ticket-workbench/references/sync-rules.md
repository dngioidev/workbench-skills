# Sync Rules

Full rules for syncing Jira issue data (and linked Confluence pages) into the local `jira-workbench/` workspace.

---

## Atlassian Rovo MCP Assumptions

When reading from the Atlassian Rovo MCP, Claude can access (via `getJiraIssue` / `searchJiraIssuesUsingJql`):

| Field | Notes |
|---|---|
| Issue key | e.g. `PROJ-123` — the full key, always including the project prefix |
| Issue type | `issuetype.name` — project-specific, see `ticket-type-normalization.md` |
| Summary | Short title |
| Description | Full description (markdown or ADF, depending on `responseContentFormat`) |
| Status | `status.name` (project-specific display text) |
| Status category | `status.statusCategory.key` — portable: `new` / `indeterminate` / `done` |
| Priority | `priority.name` |
| Assignee | `assignee.displayName` |
| Labels | Array of label strings |
| Components | Array of component objects |
| Fix version(s) | `fixVersions` |
| Parent | `parent` (epic or parent story, when hierarchy is used) |
| Subtasks | `subtasks` array |
| Due date | `duedate` |
| Updated | `updated` — timestamp of last change in Jira; this is the Jira equivalent of ADO's `changedDate` |
| Created | `created` |
| Comments | Only when `fields` includes `"comment"` — `fields.comment.comments` |
| URL | Build as `https://{site}/browse/{key}`, or use the `webUrl` the search tool already returns |

There is **no** direct equivalent of ADO's Area Path / Iteration Path fields. The nearest Jira concepts are `project`, `components`, `labels`, `fixVersions`, and (if the board exposes it) sprint — don't invent a field that doesn't exist on this site.

---

## Full Sync Algorithm

When reading a ticket from the Atlassian Rovo MCP:

1. **Detect the issue key** from the user's request or context (pattern: `[A-Z][A-Z0-9]*-[0-9]+`, e.g. `PROJ-123`).
2. **Read the issue** via `getJiraIssue` (single ticket) or `searchJiraIssuesUsingJql` (multiple) — request only the fields you need (see the field table above); avoid `"*all"` unless specifically hunting for a custom field.
3. **Normalize the issue type** to a folder name (see `ticket-type-normalization.md`).
4. **Detect complexity** (issue type, subtask count, story points if `storyPointsFieldId` is configured). If nothing is configured/available, proceed on type alone.
5. **Choose documentation mode** based on type and complexity (see `documentation-modes.md`).
6. **Create the ticket folder** if it does not exist: `jira-workbench/{type}/{ticketId}/`
7. **Create or update `{ticketId}_description.md`:**
   - Compare `updated` from Jira vs `lastSyncedFromJira` in the local file's frontmatter.
   - If Jira's `updated` is **newer**: update only the `JIRA_MANAGED` sections. Do not touch `LOCAL_NOTES` sections.
   - If local file does not exist: create it fresh from the description template.
   - If Jira is **not newer** and local file exists: skip update (no changes needed).
8. **Preserve all local/human sections** — any section between `<!-- LOCAL_NOTES_START -->` and `<!-- LOCAL_NOTES_END -->`, or sections listed in `preserveSections` in `config.yml`.
9. **Discover/refresh linked Confluence pages** — see `confluence-integration.md`. Summarize into the description's Related Documentation section.
10. **Append a sync event to `{ticketId}_sync_log.md`** — include timestamp, Jira `updated` value, files updated, and source status.
11. **Create or update `{ticketId}_route_map.md`** — update current status and last synced step.
12. **Update `jira-workbench/index.md`** — upsert the row for this ticket.
13. **Update `jira-workbench/{type}/index.md`** — upsert the row for this ticket.
14. **Update `jira-workbench/manifest.json`** — upsert the entry for this ticket.
15. **Mention all created or updated file paths** at the end of the response.
16. **Report the documentation mode chosen** and any optional files that were also created.

---

## Pagination — Avoiding Token-Limit Failures

`searchJiraIssuesUsingJql` returns verbose, deeply-nested field objects (status categories, avatar URLs, project metadata, etc.). Pulling more than roughly **40-50 issues with full field objects in one call reliably exceeds the tool's output token limit** and the call fails outright rather than truncating usefully.

Before a bulk pull (e.g. syncing an epic's children, or building a project overview):

1. First call with `searchResultMode: "count"` to see how many issues match — this tells you how many pages you'll need.
2. Paginate with `maxResults` around **25-30** and follow `nextPageToken` between calls.
3. Request only the `fields` you actually need for the task at hand (see the field table above) — never default to `"*all"` for a bulk pull.
4. If a call still fails with a token-limit error, the response is saved to a file on disk — read it in chunks rather than retrying with the same parameters.

---

## When the Atlassian Rovo MCP Is Unavailable

If the MCP is not reachable or returns an error:

- Continue from existing local files in `jira-workbench/`.
- **Clearly state** at the start of the response: "Atlassian Rovo MCP is unavailable — continuing from local context. Ticket data may be stale."
- Do not attempt to invent or guess ticket field values.
- Proceed with the user's intent using available local context.
- Offer to retry the sync when the MCP becomes available.

---

## Stale Context Rule

If `lastSyncedFromJira` in the local file's frontmatter is older than `staleAfterDays` (default: 3 days from `config.yml`):

- Warn before planning, reviewing, or closing a ticket: "Local context may be stale (last synced: {date}). Consider refreshing from Jira first."
- Do not block the user's request. Warn and proceed.

---

## Active vs Done Ticket Refresh Policy

| Ticket Status Category | Refresh Policy |
|---|---|
| `new` / `indeterminate` (i.e. not done) | Refresh if Jira `updated` is newer than local `lastSyncedFromJira` |
| `done` | Refresh only when explicitly requested by the user |

Use `status.statusCategory.key`, **not** the raw status name, to decide this — status *names* are project-specific ("To Do"/"In Progress"/"Done" on one project, something else entirely on another), but the three status *categories* (`new`, `indeterminate`, `done`) are a fixed Jira platform concept and always mean the same thing.

---

## Section-Based Updates

When updating an existing file, prefer section-based updates over full rewrites:

1. Locate the `<!-- JIRA_MANAGED_START -->` block.
2. Replace only the content between `JIRA_MANAGED_START` and `JIRA_MANAGED_END`.
3. Leave all other content unchanged.
4. Update the `lastSyncedFromJira` value in frontmatter.
5. Do not reformat or restructure the rest of the file.

This keeps the file easy to diff in Git and preserves human edits.

---

## Sync Log Entry Format

Each sync appends a new entry to `{ticketId}_sync_log.md`. Format:

```markdown
## Sync — {ISO timestamp}

- **Source:** Atlassian Rovo MCP (Jira)
- **Jira Updated:** {jiraUpdated}
- **Jira Status:** {status} ({statusCategory})
- **Files Updated:** {comma-separated list}
- **Documentation Mode:** {mode}
- **Confluence Pages Linked:** {comma-separated titles, or "none found"}
- **Notes:** {any relevant notes, e.g. "Jira was newer — description refreshed"}
```

If the MCP was unavailable, log it:

```markdown
## Sync — {ISO timestamp}

- **Source:** Local files only (Atlassian Rovo MCP unavailable)
- **Files Updated:** none
- **Notes:** Atlassian Rovo MCP unreachable — continued from local context
```

---

## Index Update Format

### jira-workbench/index.md

Human-readable table of all tracked tickets. Upsert the row for the current ticket.

```markdown
| Ticket | Type | Title | Status | Mode | Last Synced |
|---|---|---|---|---|---|
| PROJ-123 | story | Add CSV export to the reports page | In Progress | quickTrack | 2026-09-16 |
```

### jira-workbench/{type}/index.md

Same format, scoped to that ticket type.

---

## Manifest Update Format

`jira-workbench/manifest.json` is a JSON array. Upsert by `ticketId`.

```json
[
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
]
```

Set `contextPack` to `null` if no context pack file exists yet.

---

## Epic (and Parent-Story) Child Sync

When updating an epic or parent overview:

1. Read the parent issue from the Atlassian Rovo MCP.
2. Read all child tickets — try `parent = {epicKey}` first (team-managed projects / hierarchy-enabled sites); if that returns nothing, try `"Epic Link" = {epicKey}` (classic company-managed projects' legacy epic-link field).
3. For each child whose `statusCategory` is **not** `done`, check the latest `updated` timestamp.
4. Refresh local `{childId}_description.md` if Jira is newer.
5. Summarize child progress into the parent `{ticketId}_overview.md`.
6. Update `{ticketId}_relationship_map.md`.
7. Update `route_map`, `context_pack`, indexes, and manifest.

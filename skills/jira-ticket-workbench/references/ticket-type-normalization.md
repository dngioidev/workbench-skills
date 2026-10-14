# Ticket Type Normalization

Maps a Jira project's issue types to lowercase folder names used in `jira-workbench/`.

Unlike Azure DevOps (one fixed work-item-type list org-wide), **Jira issue types are configured per project** — the `PROJ` project might offer Epic/Story/Task/Subtask while another project on the same site offers Epic/Story/Bug/Subtask with no plain Task at all. Treat the table below as a set of common conventions, not a closed universe.

---

## Type Map

| Jira Issue Type | Normalized Folder |
|---|---|
| `Epic` | `epic` |
| `Story` | `story` |
| `Task` | `task` |
| `Subtask` / `Sub-task` | `subtask` |
| `Bug` | `bug` |
| `Spike` | `spike` (if the project defines one) |
| Unknown | look up the project's real scheme first (see below); fall back to `task` and note the uncertainty |

---

## Normalization Rules

1. Match the issue's `issuetype.name` (case-insensitive) against the table above.
2. If it's not a recognizable match, call `getJiraProjectIssueTypesMetadata` (or `getJiraIssueTypeMetaWithFields` for one type) for the issue's project to see its actual configured issue types before guessing — a project may have renamed or added types (e.g. "Improvement", "Change Request", "Test Case").
3. Use the normalized folder name for the ticket's path in `jira-workbench/`.
4. Store the **normalized** folder name in the file's frontmatter as `ticketType` (e.g. `story`, `bug`, `epic`).
5. Store the **original** Jira issue type string in frontmatter as `ticketTypeOriginal` only when it differs from the normalized name, or for unfamiliar/fallback types.

---

## Unknown Type Handling

If the issue type doesn't match the table and the project-metadata lookup doesn't clarify it:

1. Try to infer the type from context (summary, description, parent type, or whether it has subtasks/a parent).
2. If inference is confident, use the inferred folder. Note it in the `sync_log`.
3. If inference is not confident, use `task` as the fallback folder.
4. Add a note to the description file:
   ```markdown
   > ⚠️ Issue type "{originalType}" is not in the standard type map. Normalized to `task` as a fallback. Update if incorrect.
   ```
5. Log the uncertainty in the `sync_log`.

---

## Normalization Examples

| Input (Jira Issue Type) | Output (Folder) | Notes |
|---|---|---|
| `Epic` | `epic` | Exact match |
| `Story` | `story` | Exact match |
| `Task` | `task` | Exact match |
| `Subtask` | `subtask` | Exact match |
| `Bug` | `bug` | Exact match |
| `Spike` | `spike` | Exact match, only if the project has this type |
| `Improvement` | `task` | Fallback — note uncertainty, check project metadata first |
| `Test Case` | `task` | Fallback — note uncertainty, check project metadata first |

---

## Frontmatter Example

For a `Story` with key `PROJ-123`:

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

For an issue with an unfamiliar type, add a note:

```yaml
---
ticketId: PROJ-200
ticketType: task
ticketTypeOriginal: Improvement
ticketTypeNormalizationNote: "Unfamiliar type 'Improvement' — normalized to task as fallback"
title: Example unfamiliar type
...
---
```

---

## Documentation Mode Implications

| Normalized Type | Default Mode |
|---|---|
| `epic` | overviewTrack |
| `story` | quickTrack (simple) or deliveryTrack (complex / story points ≥5 when configured) |
| `task` | quickTrack (usually), deliveryTrack if clearly multi-step |
| `subtask` | quickTrack, almost always |
| `bug` | quickTrack (if root cause known) or investigationTrack (if unknown) |
| `spike` | quickTrack (usually low effort) or deliveryTrack if complex |

---

## ticketTypeLabel Values

Use these labels in file headings (e.g. `# Story PROJ-123 — Title`). Never use the raw normalized folder name as a heading label.

| Normalized type (`ticketType`) | Display label (`ticketTypeLabel`) |
|---|---|
| `epic` | `Epic` |
| `story` | `Story` |
| `task` | `Task` |
| `subtask` | `Subtask` |
| `bug` | `Bug` |
| `spike` | `Spike` |

For unfamiliar/fallback types, use the original Jira issue type string as the label, or `Task` if that's also unclear.

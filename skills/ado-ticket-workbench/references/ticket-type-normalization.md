# Ticket Type Normalization

Maps Azure DevOps work item type names to lowercase folder names used in `ticket-workbench/`.

---

## Type Map

| Azure DevOps Work Item Type | Normalized Folder |
|---|---|
| `Epic` | `epic` |
| `Feature` | `feature` |
| `Product Backlog Item` | `pbi` |
| `User Story` | `pbi` |
| `PBI` | `pbi` |
| `Bug` | `bug` |
| `Spike` | `spike` |
| `Task` | `pbi` (fallback — note uncertainty) |
| `Issue` | `pbi` (fallback — note uncertainty) |
| `Test Case` | `pbi` (fallback — note uncertainty) |
| Unknown | `pbi` (fallback — note uncertainty) |

---

## Normalization Rules

1. Match the Azure DevOps work item type field value (case-insensitive) against the table above.
2. Use the normalized folder name for the ticket's path in `ticket-workbench/`.
3. Store the **normalized** folder name in the file's frontmatter as `ticketType` (e.g. `pbi`, `bug`, `epic`).
4. Store the **original** Azure DevOps work item type string in frontmatter as `ticketTypeOriginal` when it differs from the normalized name (e.g. `Product Backlog Item`, `User Story`). Always include it for unknown/fallback types.

---

## Unknown Type Handling

If the Azure DevOps work item type is not in the table above:

1. Try to infer the type from context (description, title, area path, or parent type).
2. If inference is confident, use the inferred folder. Note it in the `sync_log`.
3. If inference is not confident, use `pbi` as the fallback folder.
4. Add a note to the description file:
   ```markdown
   > ⚠️ Work item type "{originalType}" is not in the standard type map. Normalized to `pbi` as a fallback. Update if incorrect.
   ```
5. Log the uncertainty in the `sync_log`.

---

## Normalization Examples

| Input (ADO Type) | Output (Folder) | Notes |
|---|---|---|
| `Epic` | `epic` | Exact match |
| `Feature` | `feature` | Exact match |
| `Product Backlog Item` | `pbi` | Exact match |
| `User Story` | `pbi` | Treated as PBI |
| `PBI` | `pbi` | Abbreviation match |
| `Bug` | `bug` | Exact match |
| `Spike` | `spike` | Exact match |
| `Task` | `pbi` | Fallback — note uncertainty |
| `Improvement` | `pbi` | Fallback — note uncertainty |
| `Test Plan` | `pbi` | Fallback — note uncertainty |

---

## Frontmatter Example

For a `Product Backlog Item` with ID 12345:

```yaml
---
ticketId: 12345
ticketType: pbi
title: Example PBI title
status: In Progress
documentationMode: quickTrack
source: azure-devops
azureDevOpsChangedDate: 2026-05-29T09:55:00+07:00
lastSyncedFromAzureDevOps: 2026-05-29T10:30:00+07:00
generatedBy: claude
---
```

For a work item with unknown type, add a note:

```yaml
---
ticketId: 99999
ticketType: pbi
ticketTypeOriginal: Improvement
ticketTypeNormalizationNote: "Unknown type 'Improvement' — normalized to pbi as fallback"
title: Example unknown type
...
---
```

---

## Documentation Mode Implications

| Normalized Type | Default Mode |
|---|---|
| `epic` | overviewTrack |
| `feature` | overviewTrack |
| `pbi` | quickTrack (effort 1–3) or deliveryTrack (effort 5–8) |
| `bug` | quickTrack (if root cause known) or investigationTrack (if unknown) |
| `spike` | quickTrack (usually low effort) or deliveryTrack if complex |

---

## ticketTypeLabel Values

Use these labels in file headings (e.g. `# PBI 12345 — Title`). Never use the raw normalized folder name as a heading label.

| Normalized type (`ticketType`) | Display label (`ticketTypeLabel`) |
|---|---|
| `epic` | `Epic` |
| `feature` | `Feature` |
| `pbi` | `PBI` |
| `bug` | `Bug` |
| `spike` | `Spike` |

For unknown/fallback types, use the original ADO work item type string as the label, or `PBI` if that is also unknown.

---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: overviewTrack
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Relationship Map — {ticketTypeLabel} {ticketId} {title}

<!-- JIRA_MANAGED_START -->

## Parent

| Field | Value |
|---|---|
| **Key** | {ticketId} |
| **Type** | {ticketTypeOriginal} |
| **Title** | {title} |
| **Status** | {status} |
| **URL** | [{ticketId}]({url}) |

---

## Children

_Found via `parent = {ticketId}` (team-managed/hierarchy) or `"Epic Link" = {ticketId}` (classic company-managed) — see `references/sync-rules.md`._

| Ticket | Type | Status | Depends On | Blocks | Notes |
|---|---|---|---|---|---|
| [{childId}]({childUrl}) | {type} | {status} | {dependsOn} | {blocks} | {notes} |

---

## Dependency Notes

_Describe cross-ticket dependencies and sequencing constraints._

- **{ticketId} depends on {ticketId}:** {reason}

---

## Risk Notes

_Tickets with elevated risk or blocking potential._

- **{ticketId}:** {riskNote}

<!-- JIRA_MANAGED_END -->

---

## Local Notes

<!-- LOCAL_NOTES_START -->
_Notes about relationships or sequencing that are not in Jira._

<!-- LOCAL_NOTES_END -->

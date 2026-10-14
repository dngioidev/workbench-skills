---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: overviewTrack
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Relationship Map — {ticketTypeLabel} {ticketId} {title}

<!-- ADO_MANAGED_START -->

## Parent

| Field | Value |
|---|---|
| **ID** | {ticketId} |
| **Type** | {ticketTypeOriginal} |
| **Title** | {title} |
| **Status** | {status} |
| **URL** | [{ticketId}]({url}) |

---

## Children

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

<!-- ADO_MANAGED_END -->

---

## Local Notes

<!-- LOCAL_NOTES_START -->
_Notes about relationships or sequencing that are not in Azure DevOps._

<!-- LOCAL_NOTES_END -->

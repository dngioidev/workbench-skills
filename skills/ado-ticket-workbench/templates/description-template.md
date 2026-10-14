---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
status: {status}
documentationMode: {documentationMode}
source: azure-devops
azureDevOpsChangedDate: {azureDevOpsChangedDate}
lastSyncedFromAzureDevOps: {lastSyncedFromAzureDevOps}
generatedBy: claude
---

# {ticketTypeLabel} {ticketId} — {title}

<!-- ADO_MANAGED_START -->

## Metadata

| Field | Value |
|---|---|
| **ID** | {ticketId} |
| **Type** | {ticketTypeOriginal} |
| **Title** | {title} |
| **Status** | {status} |
| **Assigned To** | {assignedTo} |
| **Effort / Story Points** | {effort} |
| **Area Path** | {areaPath} |
| **Iteration** | {iterationPath} |
| **URL** | [{ticketId}]({url}) |
| **ADO Changed Date** | {azureDevOpsChangedDate} |

---

## Description

{description}

---

## Acceptance Criteria

{acceptanceCriteria}

---

<!-- ═══════════════════════════════════════════════════════════════
     BUGS ONLY — DELETE THIS ENTIRE SECTION FOR PBI, EPIC, FEATURE, SPIKE
     ═══════════════════════════════════════════════════════════════ -->
## Bug Details

**Severity:** {severity}
**Environment:** {environment}
**Reported By:** {reportedBy}

<!-- ═══════════════════════════════════════════════════════════════
     END BUGS ONLY
     ═══════════════════════════════════════════════════════════════ -->

---

## Comments Summary

{commentsSummary}
<!-- Summarize key comments — do not paste the full thread unless essential -->

---

## History Summary

{historySummary}
<!-- Summarize meaningful status changes, reassignments, or description updates -->

---

## Related Tickets

| Ticket | Type | Relationship | Status | Notes |
|---|---|---|---|---|
| {relatedTicketId} | {type} | {relationship} | {status} | {notes} |

<!-- ADO_MANAGED_END -->

---

## Current Understanding

<!-- LOCAL_NOTES_START -->
_Add your understanding of the ticket here. This section is preserved on sync._

<!-- LOCAL_NOTES_END -->

---

## Open Questions

<!-- LOCAL_NOTES_START -->
_List open questions, blockers, or ambiguities that need resolution._

<!-- LOCAL_NOTES_END -->

---

## Local Notes

<!-- LOCAL_NOTES_START -->
_Free-form notes for Claude and developers. Preserved on every sync._

<!-- LOCAL_NOTES_END -->

---

## Sync Log

_See `{ticketId}_sync_log.md` for full sync history._

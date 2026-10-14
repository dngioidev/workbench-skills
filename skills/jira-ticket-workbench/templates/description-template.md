---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
status: {status}
statusCategory: {statusCategory}
documentationMode: {documentationMode}
source: jira
cloudId: {cloudId}
jiraUpdated: {jiraUpdated}
lastSyncedFromJira: {lastSyncedFromJira}
generatedBy: claude
---

# {ticketTypeLabel} {ticketId} — {title}

<!-- JIRA_MANAGED_START -->

## Metadata

| Field | Value |
|---|---|
| **Key** | {ticketId} |
| **Type** | {ticketTypeOriginal} |
| **Title** | {title} |
| **Status** | {status} ({statusCategory}) |
| **Assignee** | {assignee} |
| **Priority** | {priority} |
| **Labels** | {labels} |
| **Components** | {components} |
| **Fix Version(s)** | {fixVersions} |
| **Project** | {project} |
| **URL** | [{ticketId}]({url}) |
| **Jira Updated** | {jiraUpdated} |

---

## Description

{description}

---

## Acceptance Criteria

{acceptanceCriteria}
<!-- Jira has no dedicated AC field by default — this is usually parsed out of the description, a custom field, or linked Confluence spec. Note where it came from if not obvious. -->

---

<!-- ═══════════════════════════════════════════════════════════════
     BUGS ONLY — DELETE THIS ENTIRE SECTION FOR NON-BUG TYPES
     ═══════════════════════════════════════════════════════════════ -->
## Bug Details

**Priority:** {priority}
**Environment:** {environment}
**Reported By:** {reporter}

<!-- ═══════════════════════════════════════════════════════════════
     END BUGS ONLY
     ═══════════════════════════════════════════════════════════════ -->

---

## Related Documentation

_Confluence pages linked to this ticket — see `references/confluence-integration.md` for how these are discovered._

| Page | Summary | Source |
|---|---|---|
| {pageLink} | {pageSummary} | {discoverySource} |

<!-- No pages found for this ticket yet. Run "note confluence page {url} against ticket {id}" to attach one manually. -->

---

## Comments Summary

{commentsSummary}
<!-- Summarize key Jira comments — do not paste the full thread unless essential -->

---

## Related Tickets

| Ticket | Type | Relationship | Status | Notes |
|---|---|---|---|---|
| {relatedTicketId} | {type} | {relationship} | {status} | {notes} |

<!-- JIRA_MANAGED_END -->

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

---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: overviewTrack
source: jira
cloudId: {cloudId}
jiraUpdated: {jiraUpdated}
lastSyncedFromJira: {lastSyncedFromJira}
generatedBy: claude
---

# Overview — {ticketTypeLabel} {ticketId} {title}

<!-- JIRA_MANAGED_START -->

## Summary

{summary}

---

## Parent Metadata

| Field | Value |
|---|---|
| **Key** | {ticketId} |
| **Type** | {ticketTypeOriginal} |
| **Title** | {title} |
| **Status** | {status} ({statusCategory}) |
| **Owner** | {assignee} |
| **Project** | {project} |
| **Components** | {components} |
| **Fix Version(s)** | {fixVersions} |
| **URL** | [{ticketId}]({url}) |
| **Last Changed (Jira)** | {jiraUpdated} |

---

## Related Documentation

_Confluence pages relevant to this epic as a whole (roadmap, architecture, requirements) — see `references/confluence-integration.md`._

| Page | Summary | Source |
|---|---|---|
| {pageLink} | {pageSummary} | {discoverySource} |

---

## Child Tickets

| Ticket | Type | Status | Last Changed | Summary | Risk |
|---|---|---|---|---|---|
| [{childId}]({childUrl}) | {type} | {status} | {lastChanged} | {summary} | {risk} |

---

## Active Work

_Children currently in progress (statusCategory != done)._

| Ticket | Title | Assigned | Status | Notes |
|---|---|---|---|---|
| {ticketId} | {title} | {assignee} | {status} | {notes} |

---

## Done / Closed Work

| Ticket | Title | Resolved Date |
|---|---|---|
| {ticketId} | {title} | {resolvedDate} |

---

## Blockers

_Active blockers preventing child ticket progress._

- {blocker}

---

## Dependencies

_External dependencies — other epics or systems._

- {dependency}

---

## Risks

| Risk | Affected Tickets | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| {risk} | {ticketIds} | Low / Medium / High | Low / Medium / High | {mitigation} |

---

## Recommended Next Steps

_Prioritised actions to move this epic forward._

1. {step}

---

## Last Refreshed

{lastRefreshed}

<!-- JIRA_MANAGED_END -->

---

## Local Notes

<!-- LOCAL_NOTES_START -->
_Notes for the team or Claude about this epic. Preserved on every sync._

<!-- LOCAL_NOTES_END -->

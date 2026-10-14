---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: overviewTrack
source: azure-devops
azureDevOpsChangedDate: {azureDevOpsChangedDate}
lastSyncedFromAzureDevOps: {lastSyncedFromAzureDevOps}
generatedBy: claude
---

# Overview — {ticketTypeLabel} {ticketId} {title}

<!-- ADO_MANAGED_START -->

## Summary

{summary}

---

## Parent Metadata

| Field | Value |
|---|---|
| **ID** | {ticketId} |
| **Type** | {ticketTypeOriginal} |
| **Title** | {title} |
| **Status** | {status} |
| **Owner** | {assignedTo} |
| **Area Path** | {areaPath} |
| **Iteration** | {iterationPath} |
| **URL** | [{ticketId}]({url}) |
| **Last Changed (ADO)** | {azureDevOpsChangedDate} |

---

## Child Tickets

| Ticket | Type | Status | Last Changed | Summary | Risk |
|---|---|---|---|---|---|
| [{childId}]({childUrl}) | {type} | {status} | {lastChanged} | {summary} | {risk} |

---

## Active Work

_Children currently in progress._

| Ticket | Title | Assigned | Status | Notes |
|---|---|---|---|---|
| {ticketId} | {title} | {assignedTo} | {status} | {notes} |

---

## Done / Closed Work

| Ticket | Title | Closed Date |
|---|---|---|
| {ticketId} | {title} | {closedDate} |

---

## Blockers

_Active blockers preventing child ticket progress._

- {blocker}

---

## Dependencies

_External dependencies — other epics, features, or systems._

- {dependency}

---

## Risks

| Risk | Affected Tickets | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| {risk} | {ticketIds} | Low / Medium / High | Low / Medium / High | {mitigation} |

---

## Recommended Next Steps

_Prioritised actions to move this epic/feature forward._

1. {step}

---

## Last Refreshed

{lastRefreshed}

<!-- ADO_MANAGED_END -->

---

## Local Notes

<!-- LOCAL_NOTES_START -->
_Notes for the team or Claude about this epic/feature. Preserved on every sync._

<!-- LOCAL_NOTES_END -->

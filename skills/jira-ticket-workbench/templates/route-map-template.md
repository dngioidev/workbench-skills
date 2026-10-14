---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: {documentationMode}
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Route Map — {ticketId} {title}

_This file is the starting point for any new Claude session on this ticket. Keep it current._

---

## Main Ticket

- **Key:** {ticketId}
- **Type:** {ticketType}
- **Title:** {title}
- **Status:** {status}
- **Jira URL:** [{ticketId}]({url})

---

## Documentation Mode

**{documentationMode}**

{documentationModeReason}

---

## Read These Files First

_Read in this order when resuming work on this ticket._

1. This route map (`{ticketId}_route_map.md`)
2. `{ticketId}_description.md` — ticket context (includes Related Documentation from Confluence)
3. `{ticketId}_plan.md` — implementation plan (if exists)
4. `{ticketId}_context_pack.md` — compact continuation context (if exists)

---

## Current Goal

_One sentence: what is the immediate goal right now?_

{currentGoal}

---

## Current Status

_What phase is the ticket in? What is the state of implementation?_

{currentStatus}

---

## Important Decisions

_Key decisions already made. Do not re-debate these without a reason._

| Decision | Rationale | Date |
|---|---|---|
| {decision} | {rationale} | {date} |

---

## Key Code Areas

_Files and modules that are central to this ticket's implementation._

| Path | Role |
|---|---|
| {path} | {role} |

---

## Related Tickets

| Ticket | Type | Relationship | Status |
|---|---|---|---|
| {ticketId} | {type} | {relationship} | {status} |

---

## Known Risks

_Active risks or concerns that should be front-of-mind._

- {risk}

---

## Last Completed Step

_The last concrete thing that was done._

{lastCompletedStep}

---

## Next Recommended Step

_The single most important thing to do next._

{nextRecommendedStep}

---

## Notes For Future Claude Sessions

<!-- LOCAL_NOTES_START -->
_Anything a new Claude session needs to know to avoid repeating past mistakes or wasted effort._

<!-- LOCAL_NOTES_END -->

---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: {documentationMode}
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Test Evidence — {ticketId} {title}

---

## Automated Tests

| Command | Result | Notes |
|---|---|---|
| `{command}` | ✅ Passed / ❌ Failed / ⚠️ Skipped | {notes} |

---

## Manual Checks

| Scenario | Steps Summary | Result | Evidence | Notes |
|---|---|---|---|---|
| {scenario} | {stepsSummary} | ✅ Pass / ❌ Fail / ⚠️ Partial | {evidence} | {notes} |

---

## Regression Checks

_Tests or checks performed to confirm existing functionality was not broken._

| Area | Check | Result | Notes |
|---|---|---|---|
| {area} | {check} | ✅ Pass / ❌ Fail | {notes} |

---

## Remaining Test Gaps

_Tests or scenarios that have not been covered and should be noted for follow-up._

- [ ] {gap}

---

## Notes

<!-- LOCAL_NOTES_START -->
_Additional testing context, environment details, or caveats._

<!-- LOCAL_NOTES_END -->

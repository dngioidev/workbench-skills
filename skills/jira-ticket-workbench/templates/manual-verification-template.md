---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: {documentationMode}
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Manual Verification — {ticketId} {title}

---

## Environment

| Field | Value |
|---|---|
| **Environment** | Local / Dev / Test / Staging / Production |
| **Branch / Build** | {branchOrBuild} |
| **Date** | {date} |
| **Tested By** | {tester} |

---

## Preconditions

_What must be true before starting verification?_

- [ ] {precondition}

---

## Verification Steps

| # | Step | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| 1 | {step} | {expected} | {actual} | ✅ Pass / ❌ Fail / ⚠️ Partial |

---

## Results

_Overall result summary._

**Overall:** ✅ Passed / ❌ Failed / ⚠️ Passed with issues

**Summary:** {summary}

---

## Screenshots / Evidence

_Links or descriptions of screenshots, logs, or other evidence._

- {evidence}

---

## Issues Found

_Any issues discovered during verification._

| # | Issue | Severity | Steps to Reproduce | Notes |
|---|---|---|---|---|
| 1 | {issue} | Low / Medium / High / Critical | {steps} | {notes} |

---

## Sign-off Notes

<!-- LOCAL_NOTES_START -->
_Sign-off status and any conditions on approval._

**Signed off by:** {signedOffBy}
**Date:** {date}
**Conditions / Notes:** {notes}

<!-- LOCAL_NOTES_END -->

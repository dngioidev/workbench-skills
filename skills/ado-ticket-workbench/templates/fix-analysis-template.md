---
ticketId: {ticketId}
ticketType: bug
title: {title}
documentationMode: investigationTrack
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Fix Analysis — {ticketId} {title}

---

## Root Cause

_Describe the confirmed or best-understood root cause of the bug._

{rootCause}

**Confidence:** Confirmed / High / Medium / Low / Unknown

---

## Impact

_What is affected by this bug? What is the blast radius?_

| Area | Impact | Severity |
|---|---|---|
| {area} | {impact} | Low / Medium / High / Critical |

---

## Fix Options

_Two or more fix approaches considered._

### Option 1: {optionTitle}

{description}

**Pros:** {pros}
**Cons / Risks:** {cons}
**Effort:** {effort}

### Option 2: {optionTitle}

{description}

**Pros:** {pros}
**Cons / Risks:** {cons}
**Effort:** {effort}

---

## Selected Fix

_Which option was chosen and why._

**Chosen:** Option {n} — {title}

**Rationale:** {rationale}

---

## Tradeoffs

_What are we accepting by choosing this fix?_

- {tradeoff}

---

## Risks

_What could go wrong with the selected fix?_

| Risk | Likelihood | Mitigation |
|---|---|---|
| {risk} | Low / Medium / High | {mitigation} |

---

## Validation Plan

_How will you know the fix is correct and complete?_

- [ ] {validationStep}

---

## Notes

<!-- LOCAL_NOTES_START -->
_Additional analysis notes or research._

<!-- LOCAL_NOTES_END -->

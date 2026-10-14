---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: investigationTrack
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Debug Log — {ticketId} {title}

_Tracks observations, experiments, and findings during debugging. Append entries — never delete._

---

## Problem

_Describe the observed problem._

{problem}

---

## Observations

<!-- LOCAL_NOTES_START -->
_What have you observed so far? Include timestamps, environment, and relevant context._

<!-- LOCAL_NOTES_END -->

---

## Logs / Evidence

<!-- LOCAL_NOTES_START -->
_Paste relevant log snippets, error messages, stack traces, or screenshots here._

```
{logContent}
```

<!-- LOCAL_NOTES_END -->

---

## Hypotheses

<!-- LOCAL_NOTES_START -->
_What might be causing this? Rate each hypothesis._

| # | Hypothesis | Confidence | Status |
|---|---|---|---|
| 1 | {hypothesis} | Low / Medium / High | Investigating / Confirmed / Ruled Out |

<!-- LOCAL_NOTES_END -->

---

## Experiments

<!-- LOCAL_NOTES_START -->
_What have you tried? What was the result?_

| # | Experiment | Result | Conclusion |
|---|---|---|---|
| 1 | {experiment} | {result} | {conclusion} |

<!-- LOCAL_NOTES_END -->

---

## Findings

<!-- LOCAL_NOTES_START -->
_Confirmed findings — what is definitely true based on evidence._

<!-- LOCAL_NOTES_END -->

---

## Current Root Cause Guess

<!-- LOCAL_NOTES_START -->
_Best current understanding of the root cause. Update as evidence accumulates._

<!-- LOCAL_NOTES_END -->

---

## Next Debug Step

<!-- LOCAL_NOTES_START -->
_What is the single most useful next debugging action?_

<!-- LOCAL_NOTES_END -->

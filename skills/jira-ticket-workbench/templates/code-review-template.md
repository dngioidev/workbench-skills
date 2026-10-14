---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: {documentationMode}
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Code Review — {ticketId} {title}

---

## Scope

_What was reviewed? Include PR link, branch, or specific commit._

{scope}

---

## Files Reviewed

| File | Lines Changed | Role |
|---|---|---|
| `{path}` | +{added} / -{removed} | {role} |

---

## Architecture / Design Notes

_Does the implementation follow the intended design? Are there structural concerns?_

{architectureNotes}

---

## Correctness

_Does the code do what the ticket requires? Are there logic errors?_

| Issue | Severity | Location | Notes |
|---|---|---|---|
| {issue} | Low / Medium / High / Critical | `{path}:{line}` | {notes} |

---

## Edge Cases

_Edge cases not handled, or handled incorrectly._

- {edgeCase}

---

## Security / Permission Concerns

_Input validation, auth checks, data exposure, or privilege issues._

- {concern}

---

## Performance Concerns

_N+1 queries, unbounded loops, missing indexes, large payloads._

- {concern}

---

## Maintainability

_Naming, complexity, documentation, test coverage._

- {concern}

---

## Required Changes

_Must be fixed before merging._

| # | Location | Issue | Recommendation |
|---|---|---|---|
| 1 | `{path}:{line}` | {issue} | {recommendation} |

---

## Suggested Improvements

_Non-blocking improvements._

| # | Location | Suggestion |
|---|---|---|
| 1 | `{path}:{line}` | {suggestion} |

---

## Notes

<!-- LOCAL_NOTES_START -->
{reviewNotes}
<!-- LOCAL_NOTES_END -->

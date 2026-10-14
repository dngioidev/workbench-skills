---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: {documentationMode}
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Comment Resolution Plan — {ticketId} {title}

---

## Context

_Where do these comments come from? PR ID, ticket comments, or code review?_

- **Source:** {source} (PR #{prId} / Ticket #{ticketId})
- **Comment count:** {count}
- **Author(s):** {authors}

---

## Comments To Resolve

| # | Comment | Author | Thread | Priority |
|---|---|---|---|---|
| 1 | {comment} | {author} | {thread} | High / Medium / Low |

---

## Resolution Plan

| # | Comment | Resolution Approach | Files To Update |
|---|---|---|---|
| 1 | {comment} | {approach} | `{path}` |

---

## Files To Update

_Consolidated list of files that will be changed._

- [ ] `{path}` — {reason}

---

## Validation Steps

_How will you verify each resolution is correct?_

- [ ] {validationStep}

---

## Response Drafts

_Draft responses to post back on resolved comments._

### Comment #{commentId}

> {originalComment}

**Response:** {draftResponse}

---

## Remaining Questions

<!-- LOCAL_NOTES_START -->
_Open questions that need clarification from reviewers before resolving._

- [ ] {question}

<!-- LOCAL_NOTES_END -->

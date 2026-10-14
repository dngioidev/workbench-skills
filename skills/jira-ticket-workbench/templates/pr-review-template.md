---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: {documentationMode}
generatedBy: claude
lastUpdated: {lastUpdated}
---

# PR Review — {ticketId} {title}

---

## PR Metadata

| Field | Value |
|---|---|
| **PR ID** | #{prId} |
| **PR Title** | {prTitle} |
| **PR URL** | [{prId}]({prUrl}) |
| **Author** | {author} |
| **Target Branch** | {targetBranch} |
| **Source Branch** | {sourceBranch} |
| **Status** | {prStatus} |
| **Related Ticket** | [{ticketId}]({ticketUrl}) |

_Atlassian Rovo's Jira tools here don't expose the Development panel — if the PR wasn't given directly by the user, ask for its URL/number rather than guessing at a linked PR._

---

## Related Ticket Context

_Brief summary of the ticket goal to guide the review._

{ticketContext}

---

## Summary

_High-level assessment of the PR._

{summary}

---

## Files Reviewed

| File | Change Type | Notes |
|---|---|---|
| `{path}` | Added / Modified / Deleted | {notes} |

---

## Findings

### Required Changes

_Issues that must be fixed before merging._

| # | File | Line | Issue | Suggested Fix |
|---|---|---|---|---|
| 1 | `{path}` | {line} | {issue} | {suggestedFix} |

### Suggestions

_Non-blocking improvements or style notes._

| # | File | Line | Suggestion |
|---|---|---|---|
| 1 | `{path}` | {line} | {suggestion} |

---

## Risks

_Concerns about correctness, security, performance, or maintainability._

- {risk}

---

## Test Recommendations

_Tests that are missing, insufficient, or should be added._

- [ ] {testRecommendation}

---

## Final Review Status

| Status | Description |
|---|---|
| ✅ Approved | Ready to merge as-is |
| 🔄 Approved with suggestions | Suggestions provided; merge at author's discretion |
| ❌ Changes required | Required changes listed above must be addressed |
| ⏸ On hold | Blocked — see Risks or notes below |

**Status:** {finalStatus}

**Notes:**

<!-- LOCAL_NOTES_START -->
{reviewNotes}
<!-- LOCAL_NOTES_END -->

# Documentation Modes

Defines the four documentation modes, their default files, config values, and selection rules.

---

## Mode Definitions

### quickTrack

Small or low-effort ticket workflow. Start minimal, add optional files only when clearly useful.

- **Default for:** Task, Subtask, or a simple Story with no complexity signals
- **Default files:** `description`, `route_map`, `sync_log`
- **Optional files (add when needed):**
  `plan`, `ac_trace`, `dev_context`, `working_notes`, `debug_log`,
  `test_evidence`, `manual_verification`, `pr_review`, `code_review`,
  `comment_resolution_plan`, `context_pack`, `final_summary`

> QuickTrack is not limited to three files. It starts minimal but can grow.
> Adding one or two optional files does **not** require upgrading to deliveryTrack.
> Upgrade only when the ticket becomes clearly multi-step, multi-file, high-risk, or likely to span multiple sessions.

---

### deliveryTrack

Full implementation workflow for medium or high-effort tickets.

- **Default for:** Story or Task that is clearly complex (many subtasks, touches multiple services, spans sessions), or has story points ≥5 **when** `storyPointsFieldId` is configured for this site (see below)
- **Default files:** `description`, `plan`, `ac_trace`, `dev_context`, `route_map`, `context_pack`, `sync_log`
- **Optional files (add when needed):**
  `working_notes`, `debug_log`, `test_evidence`, `manual_verification`,
  `pr_review`, `code_review`, `comment_resolution_plan`, `final_summary`

---

### investigationTrack

Bug investigation workflow, especially when root cause is unknown.

- **Default for:** Bug with unknown root cause
- **Trigger when any of:**
  - Root cause unknown
  - Repro steps unclear
  - Intermittent or production-only issue
  - QA-only issue
  - Cross-service or cross-boundary issue
  - Logs or debugging required
- **Default files:** `description`, `repro_notes`, `fix_analysis`, `debug_log`, `test_evidence`, `route_map`, `sync_log`
- **Optional files (add when needed):**
  `plan`, `dev_context`, `working_notes`, `manual_verification`,
  `pr_review`, `comment_resolution_plan`, `context_pack`, `final_summary`

---

### overviewTrack

Parent-level tracking workflow for epics (and stories acting as parents with many subtasks).

- **Default for:** Epic
- **Default files:** `description`, `overview`, `relationship_map`, `route_map`, `context_pack`, `sync_log`
- **Optional files (add when needed):**
  `working_notes`, `dev_context`, `pr_review`, `comment_resolution_plan`, `final_summary`

---

## Why Jira Mode Selection Is Type-First, Not Effort-First

Azure DevOps has one org-wide numeric `Effort` field, so the ADO version of this workflow could key its mode-selection almost entirely off effort. Jira has no equivalent guarantee:

- "Story points" is nearly always a **custom field** (e.g. `customfield_10016`), and its field ID is different per Jira site — sometimes per project.
- Not every project uses story points at all; some use time estimates, some use nothing.
- A generic `searchJiraIssuesUsingJql` / `getJiraIssue` call returns the field only if you know its ID to ask for it (or request `"*all"` fields, which is expensive and easy to overflow token limits on).

So: **default to choosing the mode from issue type and observable complexity** (subtask count, description length, whether it's clearly multi-service, whether the user is asking for PR review / debugging / a parent overview). Only use story points as a *refinement* once you know the real field ID for this site.

### Finding the story points field ID once, per site

1. Call `getJiraIssueTypeMetaWithFields` for a `Story` (or whichever type carries points) in the configured project.
2. Look for a field named something like "Story point estimate" or "Story Points".
3. Note its `customfield_XXXXX` ID.
4. Save it into `jira-workbench/config.yml` as `storyPointsFieldId`.
5. From then on, request that field explicitly in `fields: [...]` when fetching issues, and use the thresholds below.

---

## Mode Selection Rules

```
Issue type = Epic
  → overviewTrack (regardless of any other signal)

Issue type = Bug, root cause unknown
  → investigationTrack (even if the ticket looks small)

Issue type = Task or Subtask, no complexity signal
  → quickTrack (default)

Issue type = Story, no complexity signal, story points unknown/unconfigured
  → quickTrack (default)

storyPointsFieldId is configured AND the issue has a value:
  1, 2, or 3           → quickTrack
  5 or 8                → deliveryTrack
  13 or higher          → deliveryTrack
  0 or unset            → quickTrack
  4, 6, or 10           → judgment call: quickTrack unless the description/subtasks
                          suggest multi-step or high-risk work, then deliveryTrack

No story points field configured, but the ticket clearly is:
  multi-step, multi-file, touches several services/components,
  has many subtasks, or is explicitly called "complex"/"large"
  → deliveryTrack

User asks for PR review
  → add pr_review and/or code_review (any mode)

User asks to resolve comments
  → add comment_resolution_plan (any mode)

User asks to compact or continue later
  → add/update route_map and context_pack

User asks for testing or QA handoff
  → add test_evidence and/or manual_verification

User asks to close ticket
  → add final_summary

User explicitly asks for full planning
  → upgrade to deliveryTrack

Ticket grows multi-step, multi-file, high-risk, or spans multiple sessions
  → upgrade to deliveryTrack
```

**Never:**
- Downgrade a mode automatically
- Delete existing ticket files
- Create files that are not needed for the current task

---

## Workspace config.yml

Create this file at `jira-workbench/config.yml` on first use — see `templates/config-template.yml` for the full file with comments. Key fields beyond what ADO's version needed:

```yaml
workspaceRoot: jira-workbench

# The Atlassian site and project/space this workspace tracks.
# A wrong cloudId silently queries the wrong company's Jira — never guess it.
jira:
  cloudId: your-company.atlassian.net   # hostname or UUID cloud ID
  projectKey: PROJ
  # Optional: the real custom field ID for story points on this site, once found
  # (see "Finding the story points field ID once, per site" above). Leave unset
  # until confirmed rather than guessing a customfield_XXXXX.
  storyPointsFieldId: null

confluence:
  spaceKey: DOCS

ticketTypes:
  Epic: epic
  Story: story
  Task: task
  Subtask: subtask
  Bug: bug

# Jira's portable done-ness signal — not project-specific status names.
doneStatusCategories:
  - done

preserveSections:
  - Local Notes
  - Working Notes
  - Implementation Notes
  - Decisions
  - Manual Notes
  - Investigation Notes
  - Developer Notes

refreshPolicy:
  activeTickets: refresh-if-jira-newer
  doneTickets: refresh-only-when-requested
  staleAfterDays: 3
```

The full `documentationModes` block (default/optional files per mode) is identical in shape to the ADO version — see `templates/config-template.yml` for the complete, ready-to-copy file.

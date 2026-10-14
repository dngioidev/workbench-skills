# Documentation Modes

Defines the four documentation modes, their default files, config values, and selection rules.

---

## Mode Definitions

### quickTrack

Small or low-effort ticket workflow. Start minimal, add optional files only when clearly useful.

- **Default for:** Effort 1, 2, or 3
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

- **Default for:** Effort 5 or 8
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

Parent-level tracking workflow for epics and features.

- **Default for:** Epic or Feature
- **Default files:** `description`, `overview`, `relationship_map`, `route_map`, `context_pack`, `sync_log`
- **Optional files (add when needed):**
  `working_notes`, `dev_context`, `pr_review`, `comment_resolution_plan`, `final_summary`

---

## Mode Selection Rules

```
Effort 1, 2, or 3
  → quickTrack (default)

Effort 5 or 8
  → deliveryTrack (default)

Effort not set or unknown
  → quickTrack (default); note that effort is unset; offer to upgrade if work appears complex

Effort = 0
  → quickTrack

Effort = 4, 6, or 10
  → judgment call: use quickTrack unless ticket description suggests multi-step or high-risk work,
    in which case use deliveryTrack

Effort = 13 or higher (or t-shirt size L or XL)
  → deliveryTrack

T-shirt size S or M
  → quickTrack

Epic or Feature type
  → overviewTrack (regardless of effort)

Bug with unknown root cause
  → investigationTrack (even if effort is low)

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

Create this file at `ticket-workbench/config.yml` on first use.

```yaml
workspaceRoot: ticket-workbench

ticketTypes:
  Epic: epic
  Feature: feature
  Product Backlog Item: pbi
  User Story: pbi
  PBI: pbi
  Bug: bug
  Spike: spike

doneStatuses:
  - Done
  - Closed
  - Removed
  - Resolved

preserveSections:
  - Local Notes
  - Working Notes
  - Implementation Notes
  - Decisions
  - Manual Notes
  - Investigation Notes
  - Developer Notes

refreshPolicy:
  activeTickets: refresh-if-azure-devops-newer
  doneTickets: refresh-only-when-requested
  staleAfterDays: 3

documentationModes:
  quickTrack:
    description: Small or low-effort ticket workflow. Start with minimal files, then add optional files only when useful.
    defaultEffort:
      - 1
      - 2
      - 3
    defaultFiles:
      - description
      - route_map
      - sync_log
    optionalFiles:
      - plan
      - ac_trace
      - dev_context
      - working_notes
      - debug_log
      - test_evidence
      - manual_verification
      - pr_review
      - code_review
      - comment_resolution_plan
      - context_pack
      - final_summary

  deliveryTrack:
    description: Full implementation workflow for medium or high-effort tickets.
    defaultEffort:
      - 5
      - 8
    defaultFiles:
      - description
      - plan
      - ac_trace
      - dev_context
      - route_map
      - context_pack
      - sync_log
    optionalFiles:
      - working_notes
      - debug_log
      - test_evidence
      - manual_verification
      - pr_review
      - code_review
      - comment_resolution_plan
      - final_summary

  investigationTrack:
    description: Bug/root-cause workflow, especially when the cause is unknown.
    appliesTo:
      - bug
    triggerWhen:
      - root cause unknown
      - repro steps unclear
      - intermittent issue
      - QA-only issue
      - production-only issue
      - cross-service issue
      - logs/debugging required
    defaultFiles:
      - description
      - repro_notes
      - fix_analysis
      - debug_log
      - test_evidence
      - route_map
      - sync_log
    optionalFiles:
      - plan
      - dev_context
      - working_notes
      - manual_verification
      - pr_review
      - comment_resolution_plan
      - context_pack
      - final_summary

  overviewTrack:
    description: Epic or feature parent-child tracking workflow.
    appliesTo:
      - epic
      - feature
    defaultFiles:
      - description
      - overview
      - relationship_map
      - route_map
      - context_pack
      - sync_log
    optionalFiles:
      - working_notes
      - dev_context
      - pr_review
      - comment_resolution_plan
      - final_summary
```

# File Lifecycle

Rules for when to create, update, preserve, and extend each file type in `jira-workbench/`.

---

## General Principles

- **Create on demand.** Do not create files before they are needed.
- **Update sections, not whole files.** Prefer targeted section updates over full rewrites.
- **Preserve local content.** Never overwrite `LOCAL_NOTES` sections or sections listed in `preserveSections`.
- **Append history.** Sync logs and implementation logs grow — never replace them.
- **Mention paths.** Always report created or updated file paths at the end of a response.
- **Never delete.** Do not delete files unless the user explicitly requests it.

---

## Per-File Lifecycle

### `{ticketId}_description.md`

| Event | Action |
|---|---|
| First read/sync | Create from `description-template.md` |
| Jira is newer than local | Update `JIRA_MANAGED` sections only; preserve local sections |
| Jira is not newer | Skip update |
| User edits local notes | Local sections preserved automatically on next sync |
| Ticket moves to a `done` status category | Do not auto-update; refresh only on explicit request |
| New Confluence page discovered | Add a row to the Related Documentation table (append, don't replace existing rows) |

---

### `{ticketId}_sync_log.md`

| Event | Action |
|---|---|
| Any sync operation | Append new entry (never replace previous entries) |
| Atlassian Rovo MCP unavailable | Append entry noting unavailability |
| First sync | Create from `sync-log-template.md` and append first entry |

---

### `{ticketId}_route_map.md`

| Event | Action |
|---|---|
| First read or plan | Create from `route-map-template.md` |
| After any meaningful work session | Update current status, last completed step, next recommended step |
| Compact / continue request | Fully refresh all sections |
| After PR review or comment resolution | Update to reflect new state |

---

### `{ticketId}_context_pack.md`

| Event | Action |
|---|---|
| Compact request | Create or fully refresh from `context-pack-template.md` |
| Multi-session work anticipated | Create proactively |
| After major decision or direction change | Update current state and next step |

---

### `{ticketId}_plan.md`

| Event | Action |
|---|---|
| Plan intent detected | Create from `plan-template.md` |
| Implementation progresses | Append to Implementation Log section |
| Scope changes | Update relevant sections; preserve existing log entries |

---

### `{ticketId}_ac_trace.md`

| Event | Action |
|---|---|
| Planning or deliveryTrack | Create from `ac-trace-template.md` |
| AC items completed | Update Status column for relevant rows |
| New AC added in Jira | Add new rows |

---

### `{ticketId}_dev_context.md`

| Event | Action |
|---|---|
| Planning or deliveryTrack | Create from `dev-context-template.md` |
| New branch or PR created | Add to Branches / Pull Requests sections |
| Key files identified | Add to Key Files section |
| Environment notes change | Update Environment Notes section |

---

### `{ticketId}_working_notes.md`

| Event | Action |
|---|---|
| User wants to track decisions or findings | Create from `working-notes-template.md` |
| New decision or assumption | Append to relevant section |
| Never auto-clear | Preserve all content |

---

### `{ticketId}_debug_log.md`

| Event | Action |
|---|---|
| Investigation or debugging starts | Create from `debug-log-template.md` |
| New observation or experiment | Append to relevant section |
| Root cause found | Update Root Cause Guess and Findings |

---

### `{ticketId}_repro_notes.md`

| Event | Action |
|---|---|
| investigationTrack starts | Create from `repro-notes-template.md` |
| Repro confirmed or refined | Update Repro Steps and Frequency |

---

### `{ticketId}_fix_analysis.md`

| Event | Action |
|---|---|
| Root cause identified or hypothesised | Create from `fix-analysis-template.md` |
| Fix option chosen | Update Selected Fix and Tradeoffs |
| Validation plan confirmed | Update Validation Plan |

---

### `{ticketId}_pr_review.md`

| Event | Action |
|---|---|
| PR review requested | Create from `pr-review-template.md` |
| Additional review rounds | Update Findings and Final Review Status |

---

### `{ticketId}_code_review.md`

| Event | Action |
|---|---|
| Code review requested | Create from `code-review-template.md` |
| Iteration review | Update findings sections |

---

### `{ticketId}_comment_resolution_plan.md`

| Event | Action |
|---|---|
| Comment resolution requested | Create from `comment-resolution-template.md` |
| Comments resolved | Update resolution status per comment |

---

### `{ticketId}_test_evidence.md`

| Event | Action |
|---|---|
| Testing or QA handoff requested | Create from `test-evidence-template.md` |
| Tests run | Update Automated Tests and Manual Checks tables |
| Regression check done | Update Regression Checks section |

---

### `{ticketId}_manual_verification.md`

| Event | Action |
|---|---|
| Manual QA walkthrough needed | Create from `manual-verification-template.md` |
| Verification complete | Update Results and Sign-off Notes |

---

### `{ticketId}_overview.md` (epic only)

| Event | Action |
|---|---|
| overviewTrack starts | Create from `overview-template.md` |
| Child ticket status changes | Update Child Tickets table |
| Active work changes | Update Active Work section |
| Blockers or risks change | Update Blockers and Risks sections |

---

### `{ticketId}_relationship_map.md` (epic only)

| Event | Action |
|---|---|
| overviewTrack starts | Create from `relationship-map-template.md` |
| Children added or removed | Update Children table |
| Dependencies change | Update Dependency Notes |

---

### `{ticketId}_final_summary.md`

| Event | Action |
|---|---|
| Close ticket requested | Create from `final-summary-template.md` |
| Never auto-create | Only on explicit close or wrap-up request |

---

## Index and Manifest Lifecycle

| File | When to Update |
|---|---|
| `jira-workbench/index.md` | After any sync, create, or status change |
| `jira-workbench/{type}/index.md` | After any sync, create, or status change |
| `jira-workbench/manifest.json` | After any sync, create, or status change |
| `jira-workbench/config.yml` | Created once on first use; updated only on explicit request |

---

## Preserved Sections (Never Overwrite)

Sections with these headers (or equivalent) must never be overwritten on sync:

- Local Notes
- Working Notes
- Implementation Notes
- Decisions
- Manual Notes
- Investigation Notes
- Developer Notes
- Any section between `<!-- LOCAL_NOTES_START -->` and `<!-- LOCAL_NOTES_END -->`

---

## File Creation Checklist

Before creating a new file, confirm:

- [ ] The file is needed for the current task or documentation mode
- [ ] The file does not already exist (check local path first)
- [ ] The correct template is being used
- [ ] Frontmatter is populated with known values
- [ ] File path follows the `{ticketId}_{purpose}.md` naming convention, with `{ticketId}` as the full Jira key (e.g. `PROJ-123`, not `49`)

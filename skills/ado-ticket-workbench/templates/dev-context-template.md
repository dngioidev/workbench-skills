---
ticketId: {ticketId}
ticketType: {ticketType}
title: {title}
documentationMode: {documentationMode}
generatedBy: claude
lastUpdated: {lastUpdated}
---

# Development Context — {ticketId} {title}

_Tracks the technical landscape for this ticket: branches, PRs, key files, and environment info._

---

## Branches

| Branch | Repo | Status | Notes |
|---|---|---|---|
| `{branchName}` | {repo} | Active / Merged / Abandoned | {notes} |

---

## Pull Requests

| PR | Title | Status | Reviewer | URL |
|---|---|---|---|---|
| #{prId} | {title} | Draft / Open / Approved / Merged | {reviewer} | [{prId}]({url}) |

---

## Key Files

_Files most relevant to this ticket's implementation._

| File / Path | Role |
|---|---|
| `{path}` | {role} |

---

## Key Components / Services

_Services, modules, APIs, or databases involved._

| Component | Role | Notes |
|---|---|---|
| {component} | {role} | {notes} |

---

## Useful Commands

_Commands to build, test, run, or debug relevant to this ticket._

```bash
# {description}
{command}
```

---

## Environment Notes

<!-- LOCAL_NOTES_START -->
_Environment-specific notes — local config, feature flags, test accounts, connection strings (no secrets)._

<!-- LOCAL_NOTES_END -->

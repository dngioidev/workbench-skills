# Confluence Integration

How this workbench finds, links, and summarizes Confluence documentation for a Jira ticket. This has no ADO equivalent — Azure DevOps tickets don't have a natural documentation counterpart the way Jira + Confluence do, so treat this as a genuinely new capability, not a port.

---

## Why This Matters

A Jira issue's `description` field is rarely the whole story — the real design decisions, architecture, or requirements often live on a Confluence page that the ticket links to, mentions, or was spawned from. A ticket-workbench that only reads Jira misses half the context a developer actually needs. Every `description` file should have a **Related Documentation** section populated from Confluence whenever discovery succeeds.

---

## Discovery Methods (try in this order, cheapest first)

### 1. Remote issue links
Call `getJiraIssueRemoteIssueLinks` for the ticket. Some organizations explicitly link a Jira issue to a Confluence page via Jira's own "Link" feature — if any remote link's URL matches the configured Confluence site (`{cloudId}/wiki/...`), that's a confirmed, human-curated link. Prefer these over anything auto-discovered.

### 2. CQL text search for the ticket key
Confluence pages often mention a ticket key in prose ("see PROJ-123 for the underlying issue"). Search:

```
searchConfluenceUsingCql:
  cql: 'text ~ "{ticketId}" AND type = page'
  cqlcontext: { spaceKey: "{confluence.spaceKey from config}" }
```

Scope to the configured space first to avoid noise from unrelated personal spaces; only broaden the search if nothing turns up and the user asks for a wider look.

### 3. Manually noted pages
`config.yml` (or a per-ticket frontmatter list) can carry pages a human explicitly attached via the **"note confluence page {url} against ticket {id}"** intent (see `SKILL.md`). Always include these — they were curated on purpose, and Claude cannot rediscover them by searching alone (e.g. an internal design doc that never mentions the ticket key by name).

### 4. Space/page-tree browse (last resort, for epics/overviews only)
For an epic or project overview, browsing the configured space's page tree (`getPagesInConfluenceSpace`, or `getConfluencePageDescendants` from the space homepage) can surface high-level docs (roadmap, architecture) that don't reference any single ticket key. Use this only when asked for a broader overview — it's too expensive to run per-ticket.

---

## Summarizing a Discovered Page

Don't dump full page bodies into a ticket's description file. For each page found:

1. Fetch it with `getConfluencePage` using `contentFormat: "markdown"` (far more compact than ADF for summarization purposes).
2. Write a short summary (2-4 sentences: what the page is, what it decides or specifies, anything directly relevant to this ticket).
3. Link it by its `webUrl` (or build one from the space's `_links.webui` base + the page's own path).
4. If the page is empty or a stub (near-zero real content — this happens more often than you'd expect, e.g. a placeholder created for a future doc), say so explicitly rather than silently guessing at content, and check whether an older/differently-named sibling page holds the real content instead.

---

## Related Documentation Section Format

Used in `{ticketId}_description.md` (see `templates/description-template.md`):

```markdown
## Related Documentation

| Page | Summary | Source |
|---|---|---|
| [Reports API Design](https://your-company.atlassian.net/wiki/spaces/DOCS/pages/100001) | Defines the export endpoint and file format referenced by this ticket's acceptance criteria. | remote link |
| [Q3 Product Roadmap](https://your-company.atlassian.net/wiki/spaces/DOCS/pages/100002) | Lists this ticket as part of the reporting improvements initiative. | CQL text match |

<!-- No pages found for this ticket yet. Run "note confluence page {url} against ticket {id}" to attach one manually. -->
```

Keep the `Source` column (`remote link` / `CQL text match` / `manually noted` / `space browse`) — it tells a future session (and a human) how much to trust the association, since a text match is a much weaker signal than a curated link.

---

## "note confluence page {url or title} against ticket {id}" Intent

1. Resolve the page: if given a URL, extract the page ID (including tiny-link `/wiki/x/{code}` URLs — `getConfluencePage` accepts the encoded tiny-link segment directly as `pageId`); if given a title, search for it with `searchConfluenceUsingCql` scoped to the configured space.
2. Confirm the resolved page with the user if the title search returned more than one plausible match.
3. Add it to the ticket's Related Documentation table with `Source: manually noted`.
4. Also record it in `config.yml` under a per-ticket manual-links map (or in the ticket's own frontmatter, whichever this workspace already uses) so a future sync doesn't need to be told again.
5. Log the addition in `sync_log`.

---

## What Not To Do

- Don't create or edit Confluence pages as a side effect of a Jira sync — documentation changes are a deliberate, separate action a user should ask for by name.
- Don't treat a CQL text match as equivalent to a confirmed link — always label the source.
- Don't re-fetch and re-summarize a page that hasn't changed since the last sync (compare the page's own `version`/`updated` if available) unless the user asks for a refresh.

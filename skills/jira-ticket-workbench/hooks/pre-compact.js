#!/usr/bin/env node
/**
 * Jira Ticket Workbench — Pre-Compact Hook
 *
 * Fires automatically before every Claude Code context compaction (auto or manual).
 *
 * Behaviour:
 *   A) Active ticket(s) are missing a route map
 *      → BLOCK compaction with a message asking Claude to run `compact ticket {id}` first.
 *        This gives Claude one last chance to write the context to disk before it is lost.
 *
 *   B) All active tickets have route maps on disk
 *      → Write a pre-compact-snapshot.md to jira-workbench/
 *        and allow compaction. The snapshot is a lightweight recovery file
 *        that survives compaction and is the first thing to read when resuming.
 *
 * This script lives inside the skill package and is referenced by the skill frontmatter
 * hooks section, which looks for it in a project, plugin, or global (~/.claude/skills) install.
 * No installation step needed — the skill references it automatically.
 *
 * Requirements: Node.js (always available wherever Claude Code runs). No npm packages.
 *
 * Note: "active" is decided by Jira's status *category* (new/indeterminate vs done),
 * not by a hardcoded status-name list — status names are project-specific in Jira,
 * but the manifest entry's `statusCategory` field is always one of the three portable
 * values, written there at sync time by the skill itself.
 */

'use strict';

const fs   = require('fs');
const path = require('path');

// ── Config ────────────────────────────────────────────────────────────────────

const WORKSPACE = 'jira-workbench';
const DONE_CATEGORY = 'done';

// ── Helpers ───────────────────────────────────────────────────────────────────

/**
 * Read all stdin and return as a string.
 */
async function readStdin() {
  return new Promise((resolve, reject) => {
    let data = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data',  chunk => { data += chunk; });
    process.stdin.on('end',   ()    => resolve(data));
    process.stdin.on('error', reject);
  });
}

/**
 * Extract the first meaningful content line from a named markdown section.
 * Skips placeholder text like {currentGoal}, HTML comments, and italic hints.
 */
function extractSection(content, sectionName) {
  const pattern = new RegExp(
    `##\\s+${sectionName}[^\\n]*\\n([\\s\\S]*?)(?:\\n##|\\n---|\s*$)`,
    'i'
  );
  const match = content.match(pattern);
  if (!match) return null;

  // Walk lines until we find a real one
  for (const raw of match[1].split('\n')) {
    const line = raw
      .replace(/<!--[^>]*-->/g, '')  // HTML comments
      .replace(/\{[^}]+\}/g,   '')  // {placeholders}
      .replace(/^_+|_+$/g,     '')  // _italic markers_
      .replace(/^\*+\s*/,      '')  // **bold**
      .replace(/^-\s+/,        '')  // - bullet
      .trim();

    if (line.length > 4) return line;
  }
  return null;
}

/**
 * Emit a JSON response and exit cleanly.
 */
function reply(obj) {
  process.stdout.write(JSON.stringify(obj));
  process.exit(0);
}

/**
 * Resolve a manifest path, or return null if it points outside the workspace.
 * manifest.json can come from a cloned repo, so never follow it elsewhere on disk.
 */
function workspacePath(cwd, relPath) {
  const root = path.resolve(cwd, WORKSPACE) + path.sep;
  const full = path.resolve(cwd, relPath);
  return full.startsWith(root) ? full : null;
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {

  // 1 ── Parse hook input from Claude Code ────────────────────────────────────
  const raw = await readStdin();
  let hookData;
  try { hookData = JSON.parse(raw); }
  catch { process.exit(0); }  // Malformed input — don't interfere

  const cwd          = hookData.cwd || process.cwd();
  const workspaceDir = path.join(cwd, WORKSPACE);
  const manifestPath = path.join(workspaceDir, 'manifest.json');

  // 2 ── No workspace yet — nothing to do ─────────────────────────────────────
  if (!fs.existsSync(manifestPath)) process.exit(0);

  let manifest;
  try { manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8')); }
  catch { process.exit(0); }

  if (!Array.isArray(manifest) || manifest.length === 0) process.exit(0);

  // 3 ── Find active (non-done) tickets ───────────────────────────────────────
  // Prefer the portable statusCategory; fall back to treating an unknown/missing
  // category as active (safer to over-preserve context than under-preserve it).
  const activeTickets = manifest.filter(
    t => (t.statusCategory || '').toLowerCase() !== DONE_CATEGORY
  );
  if (activeTickets.length === 0) process.exit(0);

  // 4 ── Check which active tickets are missing a route map on disk ────────────
  const missingRouteMap = activeTickets.filter(t => {
    const rmPath = t.routeMap && workspacePath(cwd, t.routeMap);
    return !rmPath || !fs.existsSync(rmPath);
  });

  if (missingRouteMap.length > 0) {

    // ── BLOCK: ask Claude to write context down first ─────────────────────────
    const ids      = missingRouteMap.map(t => `${t.type} ${t.ticketId}`).join(', ');
    const commands = missingRouteMap.map(t => `compact ticket ${t.ticketId}`).join('; ');

    reply({
      decision: 'block',
      reason: [
        `Jira Ticket Workbench: Route map missing for active ticket(s): ${ids}.`,
        `Run the following before compaction: ${commands}`,
        `This writes the current goal, status, decisions, and next step to disk so`,
        `nothing is lost when the conversation is compacted.`
      ].join(' ')
    });
  }

  // 5 ── All route maps exist — build snapshot ────────────────────────────────
  const now = new Date().toISOString();

  const lines = [
    `# Jira Ticket Workbench — Pre-Compaction Snapshot`,
    ``,
    `> **Generated:** ${now}`,
    `> **Trigger:** ${hookData.trigger || 'unknown'}`,
    `> **Active tickets:** ${activeTickets.length}`,
    ``,
    `This file is written automatically before every context compaction.`,
    `After compaction, run \`continue ticket {id}\` — Claude will reload the route map`,
    `and context pack and resume exactly where you left off.`,
    ``,
    `---`,
    ``
  ];

  for (const ticket of activeTickets) {

    lines.push(`## ${(ticket.type || 'ticket').toUpperCase()} ${ticket.ticketId} — ${ticket.title || 'Untitled'}`);
    lines.push(``);
    lines.push(`| Field | Value |`);
    lines.push(`|---|---|`);
    lines.push(`| Status | ${ticket.status || '—'} (${ticket.statusCategory || 'unknown category'}) |`);
    lines.push(`| Mode | ${ticket.documentationMode || '—'} |`);
    lines.push(`| Cloud ID | ${ticket.cloudId || '—'} |`);
    lines.push(`| Jira Updated | ${ticket.jiraUpdated || '—'} |`);
    lines.push(`| Last Synced | ${ticket.lastSyncedFromJira || '—'} |`);
    lines.push(`| Folder | \`${ticket.folder || '—'}\` |`);
    lines.push(`| Route Map | \`${ticket.routeMap || '—'}\` |`);
    lines.push(`| Context Pack | \`${ticket.contextPack || '—'}\` |`);
    lines.push(``);

    // Extract key sections from the route map
    const rmPath = ticket.routeMap && workspacePath(cwd, ticket.routeMap);
    if (rmPath) {
      try {
        const rmContent = fs.readFileSync(rmPath, 'utf8');

        const goal     = extractSection(rmContent, 'Current Goal');
        const status   = extractSection(rmContent, 'Current Status');
        const lastStep = extractSection(rmContent, 'Last Completed Step');
        const nextStep = extractSection(rmContent, 'Next Recommended Step');

        if (goal || status || lastStep || nextStep) {
          lines.push(`### Preserved Context`);
          lines.push(``);
          if (goal)     lines.push(`**Goal:** ${goal}`);
          if (status)   lines.push(`**Status:** ${status}`);
          if (lastStep) lines.push(`**Last done:** ${lastStep}`);
          if (nextStep) lines.push(`**Next step:** ${nextStep}`);
          lines.push(``);
        }
      } catch {
        lines.push(`_Route map exists but could not be read._`);
        lines.push(``);
      }
    }

    lines.push(`**To resume:** \`continue ticket ${ticket.ticketId}\``);
    lines.push(``);
    lines.push(`---`);
    lines.push(``);
  }

  // 6 ── Write snapshot to disk ────────────────────────────────────────────────
  const snapshotPath = path.join(workspaceDir, 'pre-compact-snapshot.md');
  try {
    fs.writeFileSync(snapshotPath, lines.join('\n'), 'utf8');
  } catch {
    // Write failure is non-fatal — still allow compaction
  }

  // 7 ── Allow compaction, show user a confirmation ────────────────────────────
  const ticketSummary = activeTickets
    .map(t => `${t.type} ${t.ticketId}`)
    .join(', ');

  reply({
    systemMessage: [
      `Jira Ticket Workbench: Context snapshot saved for`,
      `${activeTickets.length} active ticket(s) (${ticketSummary}).`,
      `→ ${WORKSPACE}/pre-compact-snapshot.md`
    ].join(' ')
  });
}

// Never crash or block compaction on unexpected errors
main().catch(() => process.exit(0));

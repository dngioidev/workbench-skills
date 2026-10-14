#!/usr/bin/env node
// Tests the PreCompact hook of every skill that ships one, using the exact command
// from its SKILL.md frontmatter. Run: node tests/test-hooks.js
'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { spawnSync } = require('child_process');

const repo = path.resolve(__dirname, '..');
const skillsDir = path.join(repo, 'skills');
let failures = 0;

function check(name, ok) {
  console.log(`${ok ? 'PASS' : 'FAIL'} ${name}`);
  if (!ok) failures++;
}

// Reads `command` and `args` of the PreCompact hook from SKILL.md frontmatter.
function hookCommand(skillMd) {
  const text = fs.readFileSync(skillMd, 'utf8');
  const command = text.match(/^\s+command:\s*"([^"]+)"/m);
  const args = text.match(/^\s+args:\s*(\[.*\])\s*$/m);
  if (!command || !args) return null;
  return { command: command[1], args: JSON.parse(args[1]) };
}

// Workspace folder each skill's hook watches, and a manifest entry that counts as active.
const fixtures = {
  'jira-ticket-workbench': { workspace: 'jira-workbench', ticket: { ticketId: 'PROJ-1', type: 'story', statusCategory: 'indeterminate' } },
  'ado-ticket-workbench': { workspace: 'ticket-workbench', ticket: { ticketId: '12345', type: 'pbi', status: 'Active' } },
};

function runHook(hook, projectDir, homeDir) {
  const env = { ...process.env, CLAUDE_PROJECT_DIR: projectDir, HOME: homeDir, USERPROFILE: homeDir };
  delete env.CLAUDE_PLUGIN_ROOT;
  const result = spawnSync(hook.command, hook.args, {
    input: JSON.stringify({ cwd: projectDir, trigger: 'auto', hook_event_name: 'PreCompact' }),
    env,
    encoding: 'utf8',
  });
  let output = null;
  try { output = JSON.parse(result.stdout); } catch { /* no JSON output */ }
  return { status: result.status, stdout: result.stdout, output };
}

const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'wb-hooks-'));
try {
  for (const name of fs.readdirSync(skillsDir)) {
    if (!fs.existsSync(path.join(skillsDir, name, 'hooks', 'pre-compact.js'))) continue;
    const fixture = fixtures[name];
    const hook = hookCommand(path.join(skillsDir, name, 'SKILL.md'));
    check(`${name}: SKILL.md declares the hook command`, hook !== null && fixture !== undefined);
    if (!hook || !fixture) continue;

    const base = path.join(tmp, name);
    const project = path.join(base, 'my project');
    const home = path.join(base, 'home');
    const workspace = path.join(project, fixture.workspace);
    fs.mkdirSync(workspace, { recursive: true });
    fs.mkdirSync(home, { recursive: true });
    const routeMap = `${fixture.workspace}/route_map.md`;
    const writeManifest = withRouteMap => fs.writeFileSync(
      path.join(workspace, 'manifest.json'),
      JSON.stringify([{ ...fixture.ticket, routeMap: withRouteMap ? routeMap : undefined }]),
    );

    // Not installed anywhere: the hook must stay silent and never block
    writeManifest(false);
    let run = runHook(hook, project, home);
    check(`${name}: not installed exits 0 silently`, run.status === 0 && run.stdout.trim() === '');

    // Global install (~/.claude/skills)
    const globalSkill = path.join(home, '.claude', 'skills', name);
    fs.cpSync(path.join(skillsDir, name), globalSkill, { recursive: true });
    run = runHook(hook, project, home);
    check(`${name}: global install blocks when route map is missing`, run.output && run.output.decision === 'block');
    fs.rmSync(globalSkill, { recursive: true, force: true });

    // Project install (<project>/.claude/skills)
    fs.cpSync(path.join(skillsDir, name), path.join(project, '.claude', 'skills', name), { recursive: true });
    run = runHook(hook, project, home);
    check(`${name}: project install blocks when route map is missing`, run.output && run.output.decision === 'block');

    // Route map present: snapshot written, compaction allowed
    writeManifest(true);
    fs.writeFileSync(path.join(project, routeMap), '## Current Goal\nShip the export button\n');
    run = runHook(hook, project, home);
    const snapshot = path.join(workspace, 'pre-compact-snapshot.md');
    check(`${name}: route map present allows compaction`, run.status === 0 && run.output && !run.output.decision);
    check(`${name}: snapshot written into the workspace`, fs.existsSync(snapshot) &&
      fs.readFileSync(snapshot, 'utf8').includes('Ship the export button'));
  }
} finally {
  fs.rmSync(tmp, { recursive: true, force: true });
}

if (failures > 0) {
  console.log(`${failures} test(s) failed`);
  process.exit(1);
}
console.log('All tests passed');

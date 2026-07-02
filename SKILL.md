---
name: chrome-automation
description: Use when Codex needs to launch, inspect, or control a local dedicated Google Chrome profile through DevTools/CDP, open URLs in local Chrome, configure chrome-devtools MCP, avoid daily-browser remote-debugging prompts, install local Chrome automation support, or troubleshoot localhost Chrome automation.
---

# Chrome Automation

Use a dedicated Chrome profile for browser automation. Do not attach to the daily Chrome profile unless the user explicitly asks and accepts the risk.

Use this skill when Codex should control a persistent local Chrome session rather than a disposable browser. It is especially suitable for opening websites, reusing saved login state, filling forms, submitting answers, navigating multi-step flows, and extracting results from authenticated pages.

This skill should be used in DOM-first mode. Prefer DOM inspection, selectors, text extraction, JavaScript evaluation, and form interaction instead of screenshot-based or image-input workflows. Ignore or avoid screenshot, vision, and image-related capabilities when the Codex session does not support image input.

By default, replies should match the user system language unless the user explicitly requests another language. The agent must not depend on screenshots or image input to understand the page.

This repository is a Codex skill. It is designed to be installed from GitHub with `npx skills add` and does not need to be published to npm.

## Setup Behavior

This skill runs its setup automatically during installation, so no manual setup step is required for most users.

If you need to re-run setup manually:

### Session and login behavior

This skill uses a dedicated Chrome profile, not a throwaway browser. Chrome is launched against the same profile directory each time, so cookies, local storage, and authenticated sessions can persist across Codex runs.

Use this when automation should remember an internal login, reuse an SSO session, or avoid repeating authentication on every run. If a site requires login, sign in once in the dedicated profile and the next run can reuse that session until the profile is cleared.

Typical use cases include:
- opening target websites in the dedicated profile
- reusing an existing login instead of signing in every time
- filling forms and submitting them
- answering quiz or questionnaire pages and submitting results
- navigating authenticated flows and extracting the final page content

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation"
"$skill_dir/scripts/setup"
```

Setup installs the skill-local Node dependency, configures Codex `chrome-devtools` MCP to use this skill, and starts the dedicated Chrome profile.

Run a health check:

```bash
"$skill_dir/scripts/doctor"
```

Uninstall and remove this skill's local state:

```bash
"$skill_dir/scripts/uninstall"
```

Uninstall removes the Codex `chrome-devtools` MCP entry, this skill directory when it is safe to remove directly, the skill-local dependency/state directory, and the dedicated Chrome profile.

Do not use `npx skills remove chrome-automation -g --agent codex -y` as the only uninstall step when cleanup matters. The current `skills` CLI removes installed skill files but does not run this skill's `scripts/uninstall` hook.

## Defaults

- Profile: `$HOME/.codex/chrome-debug-profile`
- State/dependencies: `$HOME/.codex/chrome-automation`
- Port: `9223`
- Override with `CHROME_DEBUG_PROFILE`, `CHROME_DEBUG_PORT`, `CHROME_AUTOMATION_HOME`, and `CHROME_BIN`.

## Scripts

If setup has already run, use these scripts:

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation"
```

Open a URL in that profile through CDP:

```bash
"$skill_dir/scripts/chrome-cdp-open" "https://example.com"
```

Use the required MCP wrapper for Codex `chrome-devtools`:

```bash
"$skill_dir/scripts/chrome-devtools-mcp-current"
```

## Recommended Workflow

1. Run `scripts/setup` once on a new machine.
2. Start the dedicated profile with `scripts/chrome-debug-launch`.
3. Verify the port:

```bash
lsof -Pan -iTCP:${CHROME_DEBUG_PORT:-9223} -sTCP:LISTEN
curl -sS "http://127.0.0.1:${CHROME_DEBUG_PORT:-9223}/json/version"
```

4. Open the requested page with `scripts/chrome-cdp-open`.
5. For DOM, console, network, or interaction work, use the configured `chrome-devtools` MCP in DOM-first mode. If the current Codex session does not support image input, ignore screenshot/vision-style tools and drive the page through selectors and JavaScript instead.

## Codex MCP Configuration

Codex `chrome-devtools` MCP is required for full use of this skill inside Codex. Setup performs this automatically. To do it manually:

```bash
codex mcp remove chrome-devtools
codex mcp add chrome-devtools --env npm_config_cache=/tmp/npm-cache -- "${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation/scripts/chrome-devtools-mcp-current"
```

After changing MCP configuration, start a new Codex session if the new tools are not visible.

## Troubleshooting

- `ECONNREFUSED`: dedicated Chrome is not running or the port is wrong. Start `scripts/chrome-debug-launch`.
- `Unexpected server response: 403`: relaunch with `--remote-allow-origins=*`; the launch script already includes it.
- `/json/version` works but no `DevToolsActivePort`: normal for this setup; scripts fall back to `/json/version`.
- Login/session reuse expected but not working: make sure you are not deleting the dedicated profile between runs, and log in once inside the dedicated profile.
- Repeated remote-debugging prompts: use this dedicated profile instead of the daily profile.
- Chrome not found: set `CHROME_BIN` to the Chrome executable path, then rerun setup.

## Uninstall Scope

Only this skill should use these default directories:

- Skill: `${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation`; `$HOME/.agents/skills/chrome-automation` when installed with `npx skills add -g --agent codex`
- State/dependencies: `$HOME/.codex/chrome-automation`
- Chrome profile: `$HOME/.codex/chrome-debug-profile`

Use `scripts/uninstall` when the user wants to remove the skill and its local environment together. If the skill was installed with `npx skills add`, prefer that script over manually deleting files so the `skills` lock state can be cleaned up.


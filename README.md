# Chrome Automation

A Codex skill for launching and controlling a dedicated local Google Chrome profile through Chrome DevTools/CDP.

It is designed to avoid attaching automation to a user's daily browser profile. The skill starts a separate Chrome profile, configures the `chrome-devtools` MCP server for Codex, and provides helper scripts for setup, health checks, opening URLs, and cleanup.

Unlike a typical Playwright-style setup that behaves like a fresh private session on every run, this skill reuses the same dedicated local Chrome profile. In many cases you only need to sign in once, and subsequent runs can continue with the existing login state, which is especially useful for dashboards, internal tools, and workflows that depend on staying logged in.

**中文文档**：[README.zh-CN.md](README.zh-CN.md)

## What It Provides

- Dedicated Chrome profile for automation
- Persistent session and login state in the dedicated profile
- One-command setup for local dependencies and Codex MCP configuration
- Chrome DevTools/CDP URL opening helper
- Health check script
- Uninstall script that removes the skill, state directory, and dedicated Chrome profile

## Requirements

- Codex CLI
- Google Chrome
- Node.js and npm
- macOS, Linux, or Windows Git Bash/MSYS-like shell

## Install

This is a Codex skill, not an npm package. Install it from GitHub:

```bash
npm_config_cache=/tmp/npm-cache npx --yes skills add onblog/chrome-automation -g --agent codex -y
```

You can also install from a full Git URL.

Then run setup from the installed Codex skill directory:

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation"
"$skill_dir/scripts/setup"
```

The setup script:

- installs the skill-local Node dependency under `~/.codex/chrome-automation`
- configures Codex `chrome-devtools` MCP to use this skill
- launches the dedicated Chrome profile on port `9223`

## Verify

```bash
"$skill_dir/scripts/doctor"
```

After installing a skill, restart Codex to pick up new skills.

Expected checks include Node/npm/Codex availability, local dependency installation, Chrome listening on the configured port, DevTools `/json/version`, and Codex MCP configuration.

## Usage

Open a target URL in the dedicated Chrome profile:

```bash
"$skill_dir/scripts/chrome-cdp-open" "https://example.com"
```

Use the skill in Codex:

```text
Use $chrome-automation to open https://example.com and summarize the visible page.
```

## Configuration

Environment variables:

- `CHROME_DEBUG_PROFILE`: dedicated Chrome profile directory. Default: `~/.codex/chrome-debug-profile`
- `CHROME_AUTOMATION_HOME`: skill state/dependency directory. Default: `~/.codex/chrome-automation`
- `CHROME_DEBUG_PORT`: DevTools port. Default: `9223`
- `CHROME_BIN`: explicit Chrome executable path when auto-detection fails

## Session and Login Behavior

This skill uses a dedicated Chrome profile, not a disposable browser. Chrome is launched against the same profile directory each time, so tabs, cookies, local storage, and login state can persist across runs.

If a site needs authentication, log in once inside the dedicated profile. Later runs can reuse that login until you explicitly clear it or remove the profile directory.

This is useful when automation needs to access internal sites, dashboards, or SSO-protected pages repeatedly without asking for login every time.

## Security Notes

Remote debugging can inspect and control browser pages. This skill intentionally uses a dedicated Chrome profile instead of the daily browser profile.

Do not point this skill at a daily browser profile unless the user explicitly requests it and accepts the security risk.

## Uninstall

```bash
"$skill_dir/scripts/uninstall"
```

This removes:

- Codex `chrome-devtools` MCP entry when it points to this skill
- `${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation`
- `$HOME/.agents/skills/chrome-automation` when installed with `npx skills add -g --agent codex`
- `~/.codex/chrome-automation`
- `~/.codex/chrome-debug-profile`

## License

MIT

#!/usr/bin/env bash
set -euo pipefail

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  echo "chrome-automation: node and npm are required for first-run setup." >&2
  exit 0
fi

state_dir="${CHROME_AUTOMATION_HOME:-${HOME}/.codex/chrome-automation}"
node_prefix="${state_dir}/node"
npm_cache="${npm_config_cache:-/tmp/npm-cache}"

mkdir -p "$node_prefix" "$npm_cache"
chmod +x \
  "${PWD}/scripts/chrome-debug-launch" \
  "${PWD}/scripts/chrome-cdp-open" \
  "${PWD}/scripts/chrome-devtools-mcp-current" \
  "${PWD}/scripts/doctor" \
  "${PWD}/scripts/setup" \
  "${PWD}/scripts/uninstall" \
  "${PWD}/scripts/postinstall.sh" || true

npm_config_cache="$npm_cache" npm install --prefix "$node_prefix" ws@latest --silent

if command -v codex >/dev/null 2>&1; then
  codex mcp remove chrome-devtools >/dev/null 2>&1 || true
  codex mcp add chrome-devtools --env "npm_config_cache=${npm_cache}" -- "${PWD}/scripts/chrome-devtools-mcp-current" || true
  "${PWD}/scripts/chrome-debug-launch" "about:blank" >/dev/null 2>&1 || true
  echo "chrome-automation: setup finished."
else
  echo "chrome-automation: installed. Run 'codex' and the skill will be available; Chrome launch can be done later."
fi

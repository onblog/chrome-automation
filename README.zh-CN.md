# Chrome Automation（中文说明）

这是一个 Codex Skill，用于启动和控制一个**独立的本地 Google Chrome 配置文件**，通过 Chrome DevTools / CDP 进行自动化。

它不会直接接管你的日常浏览器配置文件，而是使用一套专门用于自动化调试的 Chrome 配置，更适合 Codex 在本地进行网页打开、页面检查和自动化控制。

与 Playwright 常见的“每次运行都像全新无痕环境”不同，这个 skill 会复用同一个本地 Chrome 配置文件。很多站点只需要登录一次，后续再次打开时就能继续保留登录状态，更适合需要持续登录、访问后台系统或重复操作同一类网站的自动化场景。

## 它能做什么

- 启动一个独立的 Chrome 配置文件用于自动化
- 支持在专用配置文件里保持独立登录态
- 一键完成本地依赖和 Codex `chrome-devtools` MCP 配置
- 提供 CDP 打开 URL 的脚本
- 提供健康检查脚本
- 提供卸载脚本，可同时清理 skill、状态目录和专用 Chrome 配置文件

## 前置条件

- Codex CLI
- Google Chrome
- Node.js 和 npm
- macOS、Linux 或 Windows Git Bash / MSYS 类环境

## 安装

这是一个 Codex Skill，不是 npm 包。推荐直接从 GitHub 安装：

```bash
npm_config_cache=/tmp/npm-cache npx --yes skills add onblog/chrome-automation -g --agent codex -y
```

安装完成后，进入 Codex skill 目录执行初始化：

```bash
skill_dir="${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation"
"$skill_dir/scripts/setup"
```

`setup` 会做这些事：

- 安装 skill 本地依赖到 `~/.codex/chrome-automation`
- 配置 Codex 的 `chrome-devtools` MCP
- 启动专用 Chrome 配置文件，默认端口 `9223`

## 验证

```bash
"$skill_dir/scripts/doctor"
```

建议安装新 skill 后，重启 Codex，让新能力生效。

## 常用命令

通过 CDP 打开指定 URL：

```bash
"$skill_dir/scripts/chrome-cdp-open" "https://example.com"
```

在 Codex 里直接使用 skill：

```text
Use $chrome-automation to open https://example.com and summarize the visible page.
```

## 配置项

可通过环境变量覆盖默认路径和端口：

- `CHROME_DEBUG_PROFILE`：专用 Chrome 配置文件目录，默认 `~/.codex/chrome-debug-profile`
- `CHROME_AUTOMATION_HOME`：skill 状态和依赖目录，默认 `~/.codex/chrome-automation`
- `CHROME_DEBUG_PORT`：DevTools 端口，默认 `9223`
- `CHROME_BIN`：Chrome 可执行文件路径，自动检测失败时使用

## 会话与登录说明

这个 skill 使用的是专用 Chrome 配置文件，而不是每次新建一个一次性浏览器。每次启动都会复用同一个配置文件目录，因此 Cookie、LocalStorage 和登录状态通常会在多次运行之间保留。

如果目标站点需要登录，只要在专用配置文件里登录一次，后续自动化运行一般就可以直接复用这次登录态，而不需要每次都重新登录。

这对需要访问内部系统、后台管理页面、SSO 保护站点或需要长期保持登录状态的自动化任务特别有用。

## 安全说明

远程调试可以检查和控制浏览器页面。这个 skill 故意使用独立的 Chrome 配置文件，而不是日常浏览器。

除非你明确知道风险并主动要求，否则不要把它指向日常浏览器配置文件。

## 卸载

```bash
"$skill_dir/scripts/uninstall"
```

卸载时会尝试清理：

- Codex 的 `chrome-devtools` MCP 条目
- `${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation`
- `$HOME/.agents/skills/chrome-automation`（通过 `npx skills add` 安装时）
- `~/.codex/chrome-automation`
- `~/.codex/chrome-debug-profile`

## License

MIT

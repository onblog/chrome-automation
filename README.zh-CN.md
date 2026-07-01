# Chrome Automation（中文说明）

这是一个 Codex Skill，用于启动和控制一个**独立的本地 Google Chrome 配置文件**，通过 Chrome DevTools / CDP 进行自动化。

它不会直接接管你的日常浏览器配置文件，而是使用一套专门用于自动化调试的 Chrome 配置，更适合 Codex 在本地进行网页打开、页面检查和自动化控制。

与 Playwright 常见的“每次运行都像全新无痕环境”不同，这个 skill 会复用同一个本地 Chrome 配置文件。很多站点只需要登录一次，后续再次打开时就能继续保留登录状态，更适合需要持续登录、访问后台系统或重复操作同一类网站的自动化场景。

## 它能做什么

- 启动一个独立的 Chrome 配置文件用于自动化
- 支持在专用配置文件里保持独立登录态
- 一键完成本地依赖安装
- 配置 Codex `chrome-devtools` MCP，Codex 内的完整使用依赖它
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

安装完成后不需要再手动执行初始化，安装过程会自动完成本地依赖准备和 Codex `chrome-devtools` MCP 集成配置。

建议安装新 skill 后，重启 Codex，让新能力生效。

如果后续需要手动检查环境，可以运行：

```bash
"${CODEX_HOME:-$HOME/.codex}/skills/chrome-automation/scripts/doctor"
```

## 常用命令

通过 CDP 打开指定 URL：

```bash
"$skill_dir/scripts/chrome-cdp-open" "https://example.com"
```

在 Codex 里直接使用 skill：

```text
Use $chrome-automation to open https://example.com and summarize the visible page.
```

在 Codex 里使用这个 skill 时，`chrome-devtools` MCP 是必须的；单靠 CDP 脚本不能替代 Codex 内的 MCP 能力。

## 示例 Prompt

```text
使用 $chrome-automation 打开 https://example.com/login，完成登录后总结当前仪表盘页面的主要内容。
```

```text
使用 $chrome-automation 打开 https://example.com/form，按照给定的字段值自动填写表单，提交后返回页面显示的结果。
```

```text
使用 $chrome-automation 打开 https://example.com/quiz，按照题目规则自动答题，提交后返回最终得分或确认信息。
```

```text
使用 $chrome-automation 打开一个内部管理页面，进入目标模块并提取关键状态字段。
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

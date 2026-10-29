# Changelog

## [0.2.0] - 2026-10-29

### 变更（tmux 传输层改用 et：本地回显 + 断线重连，命令接口不变）

- **为什么改**：原来的 `macmini tmux` 走 `ssh -t`，每个按键都要等一个网络往返才有回显。实测本机到 macmini 的 WiFi 链路平均延迟 45 ms、抖动 69 ms（最大 232 ms），打字会明显发涩；而同样环境下到公网的链路反而更稳。目标是「在任何网络下打字都跟手」，不是把家里这一段换成网线。
- **改了什么**：连接层从 ssh 换成 **et（Eternal Terminal）**，et 的本地回显把抖动挡在感知之外，断网/换网络还能自动重连；tmux 仍在远端跑，负责会话持久化与交互体验。**对使用者完全透明**——`macmini tmux`、`-s <名字>`、`-a`、`-l`、`macmini <命令>` 全部保持不变。
- **两个关键实现细节**（都是实测出来的）：
  - et 的 `--name` 每次都新建会话（同名也不接），所以脚本先试 `--attach` 接回已有会话、失败再 `--name` 新建；
  - tmux 会话必须**用 ssh 预先在后台建好**（`tmux new-session -d`），不能放在 et 的远端命令里——实测 et 断开时会把它的进程树一起收走，导致 tmux 会话跟着消失。会话生命周期与 et 解耦后，断线重连才能真正接回。
- **自动回退**：本机没装 `et`、或在 tmux 里运行本命令时（et 在 tmux 内不可用，会报 `No route to host`），自动回退到原来的 ssh 行为，不影响任何现有用法。
- **验证**：本机 macOS 26 + macmini macOS 12.4；实测 `-l`、ssh 路径、et 路径、断开后 tmux 会话保留（关键回归点）。


### 变更（`.pi` 由软链接改为真实目录 + 资源引用：全局规矩 2026-10-30 修订）

- **为什么改**：2026-10-30 用户修订了子项目的智能体专属文件规则。旧形态把 `.pi` 整个挂成指向负责 Agent 的软链接，「共享」与「独占」被压在同一个符号上：子项目要放自己的配置时无处安放，硬写进 `.pi` 等于直接写进 Kit 的 Agent 项目——会瞬间影响全部兄弟子项目、并进 Agent 仓库的 git 历史。新规则分层：身份层（`AGENTS.md`）继续保持软链接一致（pi 的上下文文件没有 include 机制，超集只能靠复制、复制必然漂移）；能力层（`.pi/`）改在子项目里建真实目录，用 `settings.json` 以**路径引用** Agent 项目的资源目录，本地专属内容放自己的目录。
- **改了什么**：删除 `.pi` 软链接（原指向 `../ExecutiveAssistantAgent/.pi`），改为真实目录加 `.pi/settings.json`：`extensions` / `skills` / `prompts` / `themes` 四组各指向 `~/Developer/ExecutiveAssistantAgent/.pi/` 下对应目录，并附带本地同名目录。`AGENTS.md` 软链接保持不变。本项仅涉及开发环境配置，**不影响脚本行为与发布产物**，不涉版本号。
- **验证**：据 pi 官方文档（`settings.md`「Resources」、`skills.md` / `extensions.md`）；同批在 `xhqing` 子项目实跑 `pi --approve -p`，技能与项目级扩展均从 Agent 项目加载成功。
- **规则出处**：全局 `~/.pi/agent/docs/agents-registry.md`「智能体专属文件归属与子项目映射（2026-10-30 修订）」节。

## [0.1.0] - 2026-10-29

### 新增

- 首个版本。`macmini tmux` 不带参数时**每次开一个新会话**，名字自动按 `session#1`、`session#2` 递增（取当前最小空闲号，被删掉的号会重新启用），进会话前在本地打一行提示告诉本次会话名，方便下次按名字接回。
- `macmini tmux -s <名字>`（也可省略 `-s`、直接写名字）：接上该名字的会话，没有就新建——断线重连用这条。
- `macmini tmux -a`：接回**最近一次进去过**的会话（按 `session_last_attached` 排序；从没 attach 过的会话用 `session_activity` 兜底）。
- `macmini tmux -l`：列出 macmini 上现有的 tmux 会话。
- `macmini <其它命令...>`：把任意命令透传到 macmini 执行（本地有终端时带 `-t`）。
- `install.sh`：把 `macmini` 脚本部署到 `~/.local/bin/macmini`，采用**复制而非软链接**（开发目录与运行版本隔离，改动要重新 install 才生效）。
- 双语 README 顶部挂 logo 与标准三枚徽章（License / Version / Type），底部补「版权与署名」段；`LICENSE.md` 版权人按团队规范写 `All Contributors`。
- 文档记录状态栏截断的坑：tmux 默认 `status-left-length` 为 10，会话名 `session#1` 加上方括号和空格共 12 个字符，会被截成 `[session#1`，紧接后面的窗口序号 `0`，看起来就像 `session#10`。README 给出 `~/.tmux.conf` 里的修复写法。

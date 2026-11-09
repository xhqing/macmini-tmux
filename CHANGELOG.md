# Changelog

### 变更（Kit 项目更名为 assistant-agent，2026-11-09）

- **为什么改**：Kit 的 Agent 项目 2026-11-09 由 `ExecutiveAssistantAgent` 更名为 `assistant-agent`——项目名只求「尽可能简单、能体现主要职责」，不再要求以 `Agent` 结尾；项目性质改由 `README.md` 的 `Type-AI Agent` 徽章判定，与名字无关。本仓库是 Kit 名下的子项目，文档与规则里指代该项目的名字不同步就会指错对象。
- **改了什么**：`AGENTS.md` 归属说明两处改名；`README.md` / `README_cn.md` 的示例路径（`~/Developer/assistant-agent`）与子项目说明段改名，并更正一段过时描述——原文说「根目录 `AGENTS.md` 与 `.pi` 是指回 Agent 项目的软链接」，2026-11-08 起两边已改为完全独立，本仓库自带实体 `AGENTS.md` 与 `.pi`。

### 新增（CI 门禁：validate 检查 + main 分支 strict 保护）

- **为什么改**：用户 2026-11-03 立规「新建仓库一律必须 strict 模式的 PR CI」，并要求 28 个不合规的存量仓库统一执行最新标准。本项目此前在 PR 上没有门禁——改动合进 main 全靠人工把关，PR 可以拿旧 main 上通过的检查直接合并，回归防护存在缺口。本次补齐团队要求的「三件套」：PR 上真实跑的 CI 检查 + 挂成 required status check + `required_status_checks.strict = true`。
- **改了什么**（2026-11-03）：新增 `.github/workflows/validate.yml`（PR 与 main push 触发，检查名 `validate`）与 `.github/scripts/validate.py`（仓库卫生检查：必备文件存在、敏感文件未被跟踪、被跟踪文件不超过 10 MB、README 相对链接有效、Python / Shell 语法检查）；main 分支保护补挂 required check `validate` 并设 `strict=true`。
- **边界**：检查只做确定性、低误报的项目（required check 一旦误报就会卡住正常 PR，所以宁可少查）；不改动仓库任何原有内容。

## [未发布]

### 新增（子项目专属规则文件 `.pi/APPEND_SYSTEM.md`）

- **为什么改**：用户 2026-11-07 定下全局 Leader / Worker 分工——子项目的具体活由「以子项目根目录 / 子项目 worktree 为工作目录」的 Worker 会话干，而 pi 只加载 cwd 那一层的 `.pi/`（不向上继承）。子项目专属的硬规则没有别的地方可放：写进 Agent 项目的 `AGENTS.md` 既不会被 Worker 加载，也会污染其它兄弟子项目。
- **改了什么**：新增 `.pi/APPEND_SYSTEM.md`（49 行），只写本项目特有的硬约束——部署方式（复制成真实副本、不软链）、版本号双处一致（脚本内 `VERSION=` 与 `VERSION` 文件，`install.sh` 不一致就拒装）、实测校验清单、不许破坏的八个既有行为（et 优先 + ssh 回退、`session#N` 自动编号、`-s` 的 `-A` 语义、`-a` 接回最近、新建会话落本机 cwd 对应路径与两种回落、旧写法兼容、`--update`、环境变量覆盖）、发布不带产物。全局规则与 Kit 身份仍来自仓库根 `AGENTS.md` 软链接，文件里不重述、不覆盖。
- **影响**：纯新增规则文件，不改 `macmini` 脚本与 `install.sh`；不涉版本号（文档类改动不发版）。

## [0.3.4] - 2026-10-31

### 新增（新建会话默认落在本机当前目录对应的 macmini 路径）

- **为什么改**：用户用 cmux 侧栏看文件树时，看的是本机 `~/Developer` 的 syncthing 镜像副本；而 `macmini-tmux` 新建的会话默认停在远端 `$HOME`，两边目录对不上，侧栏跟终端永远不在同一个项目上。两机 `~/Developer` 是逐字节镜像、目录结构一致（只差 home：`/Users/xhq` → `/Users/mac`），所以完全可以把本机 cwd 直接映射过去。
- **改了什么**：新建会话时用 `tmux new-session -c <远端目录>` 指定起始目录——取本机 `$PWD`、去掉本机 `$HOME` 前缀、拼到远端 `$HOME` 上。两种边界都回落远端 `$HOME`：本机 cwd 不在 home 下（`/tmp` 之类）、远端对应目录不存在（本机刚建还没同步过去）。新增 `MACMINI_CWD=<绝对路径>` 环境变量可强制指定。`-s` / `-a` 接回已有会话时行为不变（tmux 的 duplicate session 会忽略 `-c`）。
- **验证**：本机 `~/Developer/ExecutiveAssistantAgent` → 远端 `/Users/mac/Developer/ExecutiveAssistantAgent`（用 `tmux display-message -p '#{pane_current_path}'` 实测）；`/tmp` 与「远端不存在的目录」两个边界都正确回落 `/Users/mac`。

## [0.3.3] - 2026-10-29

### 变更（去掉重复的 `tmux` 子命令）

- **为什么改**：命令名已经是 `macmini-tmux`，再跟一个 `tmux` 子命令（`macmini-tmux tmux -s dev`）读起来重复，用户直接指出不简洁。
- **改了什么**：`tmux` 子命令改为**可省略**——`macmini-tmux`、`macmini-tmux -s dev`、`macmini-tmux -l` 直接可用；旧写法 `macmini-tmux tmux ...` 保留兼容，行为完全一致。帮助里也不再重复出现两次 `tmux`。
- **验证**：新写法 `-l`、旧写法 `tmux -l`、透传 `df -h`、帮助输出全部正常。

## [0.3.2] - 2026-10-29

### 变更（`macmini-tmux` 改为真实副本 + 主推项目名）

- **为什么改**：用户指出两点。① `macmini-tmux` 原来是软链接，删掉/替换 `macmini` 就会连带失效，要的是**真实脚本文件**；② `macmini --version` 语义含混——看着像在问「macmini 这台电脑的版本」，用项目名 `macmini-tmux --version` 一眼就知道是这套 tmux 工具的版本。
- **改了什么**：`install.sh` 现在用 `install` 部署**两份真实副本**（`macmini-tmux` + 短别名 `macmini`），不再建软链接；帮助、提示文案、README 全部改用 `macmini-tmux` 作为主名（`macmini` 作为短别名保留，用法完全一致）。
- **验证**：`ls -l ~/.local/bin/macmini*` 两个都是普通文件；`macmini-tmux --version` / `--update` / `tmux -l` 全部正常。

## [0.3.1] - 2026-10-29

### 修复（et 会话名不兼容 `#`，默认命名直接连不上）

- **问题**：`macmini tmux` 的自动编号是 `session#1` 这种格式，而 **et 的会话名不允许 `#`**（也不允许空格），实测直接报 `Invalid session name: session#1` 并退出——等于默认用法完全不可用，而且退出后仍停在本机，看不出到底连没连上。
- **另一个噪音**：脚本原先会先试 `et --attach`，它失败时会把服务端已有的**全部** et 会话一股脑列到屏幕上（实测一次刷出 12 条），既乱又掩盖了真正的错误。
- **修复**：
  - et 层的会话名把非法字符（`#`、空格、`:`）换成 `-`（`session#1` → `session-1`）。**tmux 会话名保持不变**，用户看到和使用的仍然是 `session#1`。
  - 去掉「先试 `--attach`」的逻辑，直接用 `--name` 新建：tmux 会话已由 ssh 预先建好，et 层每次新建不影响「接回同一个工作区」，而且不再产生任何提示噪音。
  - 加 `--disconnect-timeout 10`，断开后的旧 et 会话 10 分钟后自动过期，不会无限累积。

## [0.3.0] - 2026-10-29

### 新增（`--version` 与 `--update`）

- **为什么加**：日常核对「装的是哪个版本」和「怎么升到最新」都要手动进仓库翻，用户要求把这两件事变成命令。
- **`macmini --version`**（也可写 `macmini-tmux --version`、`-V`）：直接打印版本号，不需要连 macmini。版本号写在脚本内部——脚本被单独复制到 `~/.local/bin` 后读不到仓库根的 `VERSION` 文件，所以两处必须同步；`install.sh` 每次安装前会比对二者，不一致直接拒绝安装并说明哪边是多少，杜绝漂移。
- **`macmini --update`**：对本地仓库执行 `git pull --ff-only` 后重新跑 `install.sh`，结束打印更新后的版本。仓库不在默认位置时用 `MACMINI_REPO=<路径>` 指定。拉取失败（本地有未提交改动、无法快进）会明确报错并提示先处理干净，不会留下半更新状态。
- **新增 `macmini-tmux` 命令名**：`install.sh` 在部署 `macmini` 后额外建一个 `macmini-tmux` 软链接指向它，两种写法等价——按项目名记命令的人不必再记别名。

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

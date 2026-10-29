<div align="center">
  <img src="assets/logo.svg" alt="macmini-tmux" width="640">

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE.md)
  [![Version](https://img.shields.io/badge/Version-0.1.0-blue)](CHANGELOG.md)
  [![Type](https://img.shields.io/badge/Type-CLI%20Tool-0D9488)](#)

  [English](README.md)
</div>

# macmini-tmux

> 一条命令连上 Mac mini 的 tmux：会话名自动编号，不用自己起名，也不会撞名。

## 为什么需要

把 Mac mini 当远程开发机用时，最常见的一步操作是「连上去，开一个能断线续跑的 tmux 会话」。直接敲 ssh 加 tmux 有两个麻烦：

- 一是要记得住会话名。名字起重了，`tmux new -s` 会报 `duplicate session`，还得先想个新的；
- 二是 `ssh -t` 不能省。少写 `-t` 就没终端，tmux 直接报 `open terminal failed`，而这个错对不熟悉 tmux 的人来说很难一眼看明白。

`macmini-tmux` 把这两件事包成一条命令：不带参数就是「开一个新的」，会话名由脚本按 `session#1`、`session#2` 递增分配，你什么都不用记；要接回旧会话时再按名字或「最近的」去接。

## 用法

| 命令 | 做什么 |
|---|---|
| `macmini tmux` | 开一个**新会话**，名字自动取最小空闲号（`session#1`、`session#2` …）；进会话前会打印本次会话名 |
| `macmini tmux -s dev` | 接上名为 `dev` 的会话；没有就新建（断线重连、固定工作区用这条） |
| `macmini tmux dev` | 同上，省略 `-s` |
| `macmini tmux -a` | 接回**最近一次进去过**的会话 |
| `macmini tmux -l` | 列出 macmini 上现有的 tmux 会话 |
| `macmini df -h` | 不碰 tmux，直接把命令透传到 macmini 执行 |
| `macmini -h` | 显示帮助 |

会话名里带 `#` 是合法的，本机 tmux 3.6b 与 macmini tmux 3.3a 上都实测可用。

## 安装

```bash
git clone https://github.com/xhqing/macmini-tmux.git
cd macmini-tmux
./install.sh
```

脚本把 `macmini` 复制到 `~/.local/bin/macmini`（`BIN_DIR=/usr/local/bin ./install.sh` 可以换位置）。这是**复制**不是软链接：日常用的一定是部署出去的那份，改仓库里的脚本要重新 `install.sh` 才生效——开发中的版本不会意外影响正在用的命令。

## 编号规则

新会话名从 `session#1` 开始往上找，**取第一个没被占用的号**：

| 现有会话 | 下一个新会话 |
|---|---|
| 没有 | `session#1` |
| `session#1` | `session#2` |
| `session#1`、`session#2` | `session#3` |
| `session#1`、`session#3`（2 号被删了） | `session#2`（空号会复用） |

`session#N` 之外的会话名（比如你手动建的 `work`）不参与编号计算，不会影响递增。

## `-a` 是怎么挑的

按 `session_last_attached`（最后一次 attach 的时间，也就是你最近一次进这个会话的时刻）取最大的那个；从没被 attach 过的会话（比如 `tmux new -d` 在后台建出来的）没有这个值，才退而看 `session_activity`（最后活动时间）。

所以「最近用过」指的是**你最后进去的那个**，不是活动量最大的那个。

## 状态栏里的 `session#10` 是怎么回事

tmux 状态栏左侧默认格式是 `[会话名] `，而 `status-left-length` 默认只给 **10 个字符**。`session#1` 加上方括号和空格一共 12 个字符，会被截成 `[session#1`（少了 `]` 和空格），紧接着窗口列表的 `0:zsh*` 就贴了上来，看起来像 `session#10:zsh*`。

这不是会话名多了个 0，而是**窗口序号 0** 和会话名连在了一起。把上限调大即可，在 `~/.tmux.conf` 里加一行：

```tmux
set -g status-left-length 40
```

改完执行 `tmux source-file ~/.tmux.conf` 立即生效，不用重启会话。

## 换一台机器 / 换 ssh 别名

脚本默认连 `mac-mini`（`~/.ssh/config` 里的 Host 别名）。要以别的别名连同一台机器，用环境变量覆盖：

```bash
MACMINI_HOST=mac-mini-lan macmini tmux
```

## 依赖

- macOS（脚本用 bash 与 `ssh -t`，tmux 本身跨平台但不做 Windows 适配）
- 目标机器装好 tmux
- ssh 已配置免密登录（推荐 `~/.ssh/config` 里设 `Host mac-mini` + 密钥）
- 建议在目标机器或本机 `~/.tmux.conf` 里加大 `status-left-length`，免得会话名被截断

## 相关

本仓库是 [ExecutiveAssistantAgent](https://github.com/xhqing/ExecutiveAssistantAgent)（Kit）的子项目。仓库根目录的 `AGENTS.md` 与 `.pi` 是指回该 Agent 项目的软链接，用于在子项目目录开会话时继承同一套规则与技能。

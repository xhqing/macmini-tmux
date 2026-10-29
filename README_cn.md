<div align="center">
  <img src="assets/logo.svg" alt="macmini-tmux" width="640">

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow)](LICENSE.md)
  [![Version](https://img.shields.io/badge/Version-0.3.2-blue)](CHANGELOG.md)
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

传输层用的是 **et（Eternal Terminal）**，不是 ssh：et 会把按键**先在本地显示、再异步同步给远端**，所以网络延迟和抖动不会变成打字卡顿；断网或换网络后也会自动重连。tmux 仍然在远端跑，负责会话持久化、分屏、状态栏这些体验——两边的长处都拿到了。**对使用者来说命令完全没变**，et 封装在脚本内部：

- 本机没装 `et`，或者你是在 tmux 里跑这条命令（et 在 tmux 内不可用），脚本会自动回退到 ssh，行为与旧版一致。

## 用法

| 命令 | 做什么 |
|---|---|
| `macmini-tmux tmux` | 开一个**新会话**，名字自动取最小空闲号（`session#1`、`session#2` …）；进会话前会打印本次会话名 |
| `macmini-tmux tmux -s dev` | 接上名为 `dev` 的会话；没有就新建（断线重连、固定工作区用这条） |
| `macmini-tmux tmux dev` | 同上，省略 `-s` |
| `macmini-tmux tmux -a` | 接回**最近一次进去过**的会话 |
| `macmini-tmux tmux -l` | 列出 macmini 上现有的 tmux 会话 |
| `macmini-tmux df -h` | 不碰 tmux，直接把命令透传到 macmini 执行 |
| `macmini-tmux --version` | 显示当前安装的版本号（短别名 `macmini --version` 等价） |
| `macmini-tmux --update` | 从本地仓库拉取最新版并重新安装 |
| `macmini-tmux -h` | 显示帮助 |

会话名里带 `#` 是合法的，本机 tmux 3.6b 与 macmini tmux 3.3a 上都实测可用。

## 安装

```bash
git clone https://github.com/xhqing/macmini-tmux.git
cd macmini-tmux
./install.sh
```

脚本在 `~/.local/bin/` 下部署**两份真实副本**：`macmini-tmux`（主名）和短别名 `macmini`，两个名字用法完全一致，删掉其中一个不影响另一个（不是软链接）。想换位置用 `BIN_DIR=/usr/local/bin ./install.sh`。这是**复制**不是软链接：日常用的一定是部署出去的那份，改仓库里的脚本要重新 `install.sh` 才生效——开发中的版本不会意外影响正在用的命令。

想升级就直接跑 `macmini-tmux --update`：它会对你本地仓库执行 `git pull --ff-only` 再重装一遍（仓库不在默认位置时用 `MACMINI_REPO=<路径>` 指定）。安装脚本会把脚本内的版本号与仓库根 `VERSION` 文件比对，不一致就拒绝安装，避免两处漂移。

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
- 想要 et 带来的「本地回显、断线重连」体验：本机与目标机器都装 `et`（本机 `brew install et`；目标机器可用 brew 或从源码编译），并在目标机器上把 `etserver` 跑起来（默认端口 2022）。没装也能用，脚本会自动走 ssh
- ssh 已配置免密登录（推荐 `~/.ssh/config` 里设 `Host mac-mini` + 密钥）
- 建议在目标机器或本机 `~/.tmux.conf` 里加大 `status-left-length`，免得会话名被截断

## 相关

本仓库是 [ExecutiveAssistantAgent](https://github.com/xhqing/ExecutiveAssistantAgent)（Kit）的子项目。仓库根目录的 `AGENTS.md` 与 `.pi` 是指回该 Agent 项目的软链接，用于在子项目目录开会话时继承同一套规则与技能。

## 许可证与署名

Copyright (c) 2026 All Contributors。基于 [MIT License](LICENSE.md) 发布。

署名：使用或引用本项目时，请保留版权声明并注明来源：[macmini-tmux](https://github.com/xhqing/macmini-tmux)。

# macmini-tmux · 项目硬约束

身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 这是什么

一条命令连上 Mac mini 的 tmux：不带参数每次开新会话（名字按 `session#1`、`session#2` 自动递增），`-s` 按名字接回或新建，`-a` 接回最近一次，`-l` 列会话，任意命令可直接透传。实现是仓库根的单 bash 脚本 `macmini`。

## 部署方式

```bash
./install.sh    # 复制部署到 ~/.local/bin/macmini-tmux（主名）与 ~/.local/bin/macmini（短别名）
```

身份与角色见本仓库根 `AGENTS.md`；团队通用规则见全局 `~/.pi/agent/AGENTS.md`，此处不重述。

## 版本号双处一致（硬性）

脚本内 `VERSION="x.y.z"` 与仓库根 `VERSION` 文件必须相同；`install.sh` 检测到不一致会**直接拒绝安装**（exit 1）。bump 时两处同改，否则别人装不上。

## 校验方式

```bash
bash -n macmini          # 语法
./macmini --version      # 版本输出
./macmini -l             # 列远端会话
./macmini df -h          # 透传
```

涉及远端交互的改动**必须实跑**（必要时 `ssh mac-mini ...` 核对远端状态），只做 `bash -n` 不算验证。

## 不许破坏的既有行为

1. **传输层 et 优先、回退 ssh**：本机没装 `et`、或当前在 tmux 里（`$TMUX` 存在）时自动回退 ssh，且 ssh 必须带 `-t`（否则 tmux 报 `open terminal failed`）。
2. **不带 `-s`**：每次新会话，会话名取「最小空闲号」的 `session#N`，不用用户起名、也不会撞名。
3. **`-s <名>`**：远端用 `tmux new -A` 兼「没有就建、有就接」，语义是断线重连。
4. **`-a`**：按最后一次 attach 时间接回最近一次进去过的会话。
5. **新建会话的起始目录**：默认落在「本机 cwd 对应的远端路径」（两机 `~/Developer` 结构一致，`/Users/xhq` → `/Users/mac`）；`MACMINI_CWD` 可强制指定；本机 cwd 不在 home 下、或远端没有对应目录时回落远端 `$HOME`。`-s` / `-a` 接回已有会话时不改它的目录。
6. **旧写法兼容**：`macmini-tmux tmux -s dev` 仍须等价于 `macmini-tmux -s dev`。
7. **`--update`** 从本地仓库重新安装，继续可用。
8. **环境变量覆盖保留**：`MACMINI_HOST` / `MACMINI_ET_USER` / `MACMINI_REPO` / `MACMINI_CWD`，不要把主机名等改成硬编码。

## 发布渠道

GitHub Release，**不带产物**（脚本靠 `install.sh` 部署）；tag 用 `v<版本>`。双语 README 徽章与 `VERSION` 保持一致。

## 边界

本项目只管「连上去 / 开会话 / 列会话 / 透传命令」；远端机器的部署、清理、同步策略另有规矩，不在这里实现。

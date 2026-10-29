# Changelog

## [0.1.0] - 2026-10-29

### 新增

- 首个版本。`macmini tmux` 不带参数时**每次开一个新会话**，名字自动按 `session#1`、`session#2` 递增（取当前最小空闲号，被删掉的号会重新启用），进会话前在本地打一行提示告诉本次会话名，方便下次按名字接回。
- `macmini tmux -s <名字>`（也可省略 `-s`、直接写名字）：接上该名字的会话，没有就新建——断线重连用这条。
- `macmini tmux -a`：接回**最近一次进去过**的会话（按 `session_last_attached` 排序；从没 attach 过的会话用 `session_activity` 兜底）。
- `macmini tmux -l`：列出 macmini 上现有的 tmux 会话。
- `macmini <其它命令...>`：把任意命令透传到 macmini 执行（本地有终端时带 `-t`）。
- `install.sh`：把 `macmini` 脚本部署到 `~/.local/bin/macmini`，采用**复制而非软链接**（开发目录与运行版本隔离，改动要重新 install 才生效）。
- 文档记录状态栏截断的坑：tmux 默认 `status-left-length` 为 10，会话名 `session#1` 加上方括号和空格共 12 个字符，会被截成 `[session#1`，紧接后面的窗口序号 `0`，看起来就像 `session#10`。README 给出 `~/.tmux.conf` 里的修复写法。

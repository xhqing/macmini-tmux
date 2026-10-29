#!/usr/bin/env bash
# macmini-tmux 安装脚本
#
# 把仓库里的 macmini 命令复制到 ~/.local/bin/macmini，供日常使用。
# 用复制而不是软链接：开发目录与运行版本隔离，改动要重新 install 才生效
# （与团队里 codef 等工具的部署方式一致）。
#
# 想装到别处：BIN_DIR=/usr/local/bin ./install.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

echo "==> 部署 macmini 命令"
mkdir -p "$BIN_DIR"
install -m 755 "$ROOT/macmini" "$BIN_DIR/macmini"
echo "    已部署：$BIN_DIR/macmini"

echo
if ! command -v macmini >/dev/null 2>&1; then
  echo "提醒：$BIN_DIR 不在 PATH 里，把下面这行加到 ~/.zshrc 后再试："
  echo "    export PATH=\"$BIN_DIR:\$PATH\""
fi
echo "完成。试试：macmini tmux"

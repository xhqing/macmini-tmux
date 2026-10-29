#!/usr/bin/env bash
# macmini-tmux 安装脚本
#
# 把仓库里的 macmini 命令复制到 ~/.local/bin/macmini，供日常使用。
# 用复制而不是软链接：开发目录与运行版本隔离，改动要重新 install 才生效
# （与团队里 codef 等工具的部署方式一致）。
#
# 同时部署两个真实副本：主名 macmini-tmux（推荐，见名知用途）+ 短别名 macmini。
# 两者都是独立文件而不是软链接：删掉/替换其中一个不会影响另一个。
#
# 想装到别处：BIN_DIR=/usr/local/bin ./install.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

# 版本一致性校验：脚本里硬编码的 VERSION 必须与仓库根 VERSION 文件相同。
# 脚本被单独复制出去后读不到 VERSION 文件，所以版本号写在脚本里；这里防止两处漂移。
script_ver=$(grep -m1 '^VERSION=' "$ROOT/macmini" | cut -d'"' -f2)
file_ver=$(cat "$ROOT/VERSION" 2>/dev/null | tr -d '[:space:]')
if [ -z "$script_ver" ] || [ -z "$file_ver" ] || [ "$script_ver" != "$file_ver" ]; then
  echo "❌ 版本不一致，拒绝安装：" >&2
  echo "   脚本内 VERSION = ${script_ver:-（缺失）}" >&2
  echo "   VERSION 文件   = ${file_ver:-（缺失）}" >&2
  echo "   先把两处改成同一个版本号再跑本脚本。" >&2
  exit 1
fi

echo "==> 部署命令（v${script_ver}）"
mkdir -p "$BIN_DIR"
# 两个都装成真实的脚本副本（不是软链接）：任一文件被删/被替换都不影响另一个
install -m 755 "$ROOT/macmini" "$BIN_DIR/macmini-tmux"
install -m 755 "$ROOT/macmini" "$BIN_DIR/macmini"
echo "    已部署：$BIN_DIR/macmini-tmux（主名，推荐用这个）"
echo "    已部署：$BIN_DIR/macmini（短别名，同一脚本的副本）"

echo
if ! command -v macmini-tmux >/dev/null 2>&1; then
  echo "提醒：$BIN_DIR 不在 PATH 里，把下面这行加到 ~/.zshrc 后再试："
  echo "    export PATH=\"$BIN_DIR:\$PATH\""
fi
echo "完成。试试：macmini-tmux tmux（查版本：macmini-tmux --version）"

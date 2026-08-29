#!/bin/bash
# 在 WSL 内运行:为仓库中的 Windows 侧配置(.wslconfig、.wezterm.lua)创建符号链接。
# Windows 用户目录从 USERPROFILE(WSL 继承的 Windows 环境变量)读取,不硬编码用户名。
set -euo pipefail

if [ -z "${USERPROFILE-}" ]; then
  echo "ERROR: USERPROFILE is not set; please run this script inside WSL." >&2
  exit 1
fi

cmd=/mnt/c/Windows/System32/cmd.exe
# Windows 用户目录的 WSL 风格路径,例如 /mnt/c/Users/<user>
win_home="$(wslpath -u "$USERPROFILE")"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # .../win
repo_root="$(dirname "$script_dir")"

# 文件符号链接使用 mklink(不带 /d;只有目录链接才用 /d)
"$cmd" /c "sudo mklink \"$(wslpath -w "$win_home/.wslconfig")\" \"$(wslpath -w "$repo_root/win/wsl2/.wslconfig")\""
"$cmd" /c "sudo mklink \"$(wslpath -w "$win_home/.wezterm.lua")\" \"$(wslpath -w "$repo_root/wezterm/wezterm.lua")\""

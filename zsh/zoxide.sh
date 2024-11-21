if command -v zoxide > /dev/null 2>&1; then
  # 只有在 zi 是别名时才取消它
  if alias zi > /dev/null 2>&1; then
    unalias zi
  fi
  # 初始化 zoxide
  eval "$(zoxide init zsh)"
fi


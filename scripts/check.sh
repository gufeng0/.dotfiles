#!/bin/bash
# Aggregated repo checks. Run from repo root or anywhere: paths are repo-relative.
# Usage: bash scripts/check.sh
set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES_DIR"

fail=0

report() {
  if [ "$1" -eq 0 ]; then
    echo "ok   $2"
  else
    echo "FAIL $2"
    fail=1
  fi
}

# --- shell syntax (grouped by real dialect) ---
while IFS= read -r f; do
  bash -n "$f" 2>/tmp/check-bash.err
  report $? "bash -n $f $( [ -s /tmp/check-bash.err ] && cat /tmp/check-bash.err )"
done < <(find scripts bin win -name '*.sh' -type f 2>/dev/null; echo lazy-restore.sh)

while IFS= read -r f; do
  zsh -n "$f" 2>/tmp/check-zsh.err
  report $? "zsh -n $f $( [ -s /tmp/check-zsh.err ] && cat /tmp/check-zsh.err )"
done < <(echo zshrc; find zsh -maxdepth 1 -type f \( -name '*.sh' -o -name '*.zsh' \) 2>/dev/null)

# --- lua syntax ---
while IFS= read -r f; do
  luajit -e "assert(loadfile('$f'))" 2>/tmp/check-lua.err
  report $? "luajit parse $f $( [ -s /tmp/check-lua.err ] && tail -1 /tmp/check-lua.err )"
done < <(find vim -name '*.lua' -type f -not -path 'vim/autoload/*' 2>/dev/null)

# --- JSON ---
for f in package.json vim/snippets/package.json vim/.luarc.json; do
  [ -f "$f" ] || continue
  jq empty "$f" 2>/tmp/check-jq.err
  report $? "jq $f $( [ -s /tmp/check-jq.err ] && cat /tmp/check-jq.err )"
done

# --- JS ---
for f in vim/node/*.mjs; do
  [ -f "$f" ] || continue
  node --check "$f" 2>/tmp/check-node.err
  report $? "node --check $f $( [ -s /tmp/check-node.err ] && cat /tmp/check-node.err )"
done

# --- neovim headless smoke ---
nvim --headless +qa >/tmp/check-nvim.log 2>&1
report $? "nvim --headless +qa (log: /tmp/check-nvim.log)"

rm -f /tmp/check-bash.err /tmp/check-zsh.err /tmp/check-lua.err /tmp/check-jq.err /tmp/check-node.err

if [ "$fail" -eq 0 ]; then
  echo "all checks passed"
else
  echo "some checks failed"
fi
exit "$fail"

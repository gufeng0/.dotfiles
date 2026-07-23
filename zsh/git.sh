# git aliases
alias gmc='sh ~/tools/script/gmc.sh'
alias gck='git checkout'
alias glc='python3 ~/tools/script/xhyd/deploy.py'
alias gl='git pull'
alias gst='git status'
alias gca='git commit -a'

# gp => 先更新当前分支，无上游则建立 origin 跟踪，再推送
gp() {
  local current
  current=$(git branch --show-current 2>/dev/null)
  if [[ -z "$current" ]]; then
    echo "gp: 当前不在分支上（可能是 detached HEAD）"
    return 1
  fi
  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "gp: 远端 origin 不存在，请先 git remote add origin <url>"
    return 1
  fi

  echo ">> 更新当前分支: $current"
  if git fetch origin "$current" 2>/dev/null; then
    git merge --ff-only "origin/$current" || return $?
  else
    echo ">> 跳过: 远端不存在 origin/$current"
  fi

  if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
    echo ">> 推送 $current"
    git push "$@"
  else
    echo ">> 推送并设置上游: origin/$current"
    git push -u origin HEAD "$@"
  fi
}

# gm a => 更新当前分支 → 更新 a → 合并 a 到当前分支
gm() {
  if [ -z "$1" ]; then
    echo "用法: gm <分支> [merge 参数...]"
    return 1
  fi

  local branch="$1"
  shift

  local current
  current=$(git branch --show-current 2>/dev/null)
  if [[ -z "$current" ]]; then
    echo "gm: 当前不在分支上（可能是 detached HEAD）"
    return 1
  fi
  if [[ "$branch" == "$current" ]]; then
    echo "gm: 不能把分支合并到自身: $branch"
    return 1
  fi
  # 只拦已跟踪改动；未跟踪文件忽略
  if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "gm: 工作区有未提交改动，请先 commit 或 stash"
    git status --short
    return 1
  fi

  echo ">> 更新当前分支: $current"
  if git fetch origin "$current" 2>/dev/null; then
    git merge --ff-only "origin/$current" || return $?
  else
    echo ">> 跳过: 远端不存在 origin/$current"
  fi

  echo ">> 更新分支: $branch"
  gfo "$branch" || return $?

  echo ">> 合并 $branch → $current"
  git merge "$branch" "$@"
}

# gfo xxx => git fetch origin xxx:xxx
gfo() {
  if [ -z "$1" ]; then
    echo "用法: gfo <分支>"
    return 1
  fi
  git fetch origin "$1:$1"
}

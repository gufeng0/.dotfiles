# git aliases
alias gmc='sh ~/tools/script/gmc.sh'
alias gck='git checkout'
alias gst='git status'
alias gca='git commit -a'

# 获取当前分支名；$1 为调用方命令名（错误提示用）
_g_current_branch() {
  local current
  current=$(git branch --show-current 2>/dev/null)
  if [[ -z "$current" ]]; then
    echo "${1:-git}: 当前不在分支上（可能是 detached HEAD）" >&2
    return 1
  fi
  echo "$current"
}

# 更新当前分支：有上游则 git pull，无上游则跳过
# $1: 当前分支名
_g_update_current() {
  local current="$1"
  echo ">> 更新当前分支: $current"
  if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
    git pull
  else
    echo ">> 跳过: 当前分支无上游"
    return 0
  fi
}

# gl => 远端有同名分支则 pull；没有则提示用 gp
gl() {
  local current
  current=$(_g_current_branch gl) || return 1

  if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
    echo ">> 拉取 $current"
    git pull "$@"
  elif git ls-remote --exit-code --heads origin "$current" >/dev/null 2>&1; then
    echo ">> 拉取 origin/$current 并设置上游"
    git pull --set-upstream origin "$current" "$@"
  else
    echo "gl: 远端不存在 origin/$current，请用 gp 创建并推送"
    return 1
  fi
}

# gp => 先更新当前分支再推送；无上游则创建远端并设置跟踪
gp() {
  local current
  current=$(_g_current_branch gp) || return 1

  _g_update_current "$current" || return $?

  if git rev-parse --abbrev-ref @{upstream} >/dev/null 2>&1; then
    echo ">> 推送 $current"
    git push "$@"
  else
    echo ">> 无上游，创建并推送: origin/$current"
    git push -u origin HEAD "$@"
  fi
}

# gm a => 更新当前分支 → fetch a → 合并 origin/a 到当前分支
# 合并 origin/a 而非本地 a：worktree 下本地 a 常被占用或过期
gm() {
  if [ -z "$1" ]; then
    echo "用法: gm <分支> [merge 参数...]"
    return 1
  fi

  local branch="$1"
  shift

  local current
  current=$(_g_current_branch gm) || return 1
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
  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "gm: 远端 origin 不存在，请先 git remote add origin <url>"
    return 1
  fi

  _g_update_current "$current" || return $?

  echo ">> 拉取最新: origin/$branch"
  git fetch origin "$branch" || return $?

  echo ">> 合并 origin/$branch → $current"
  git merge "origin/$branch" "$@"
}

# gcb <新分支> => 先更新当前分支，再从当前分支切出新分支
gcb() {
  if [ -z "$1" ]; then
    echo "用法: gcb <新分支名>"
    return 1
  fi

  local new_branch="$1"
  shift

  local current
  current=$(_g_current_branch gcb) || return 1
  if [[ "$new_branch" == "$current" ]]; then
    echo "gcb: 新分支名不能与当前分支相同: $new_branch"
    return 1
  fi
  if git rev-parse --verify "refs/heads/$new_branch" >/dev/null 2>&1; then
    echo "gcb: 本地分支已存在: $new_branch"
    return 1
  fi
  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "gcb: 远端 origin 不存在，请先 git remote add origin <url>"
    return 1
  fi

  _g_update_current "$current" || return $?

  echo ">> 从 $current 切出新分支: $new_branch"
  git checkout -b "$new_branch" "$@"
}

# gf xxx => 拉取 origin/xxx；若本地分支未被任何 worktree 占用，则同步本地 xxx
gf() {
  if [ -z "$1" ]; then
    echo "用法: gf <分支>"
    return 1
  fi
  local branch="$1"
  # 先更新远程跟踪分支 origin/$branch（始终安全）
  git fetch origin "$branch" || return $?
  # 尝试同步本地分支；若该分支在本 worktree 或其他 worktree 被 checkout，则跳过
  if git rev-parse --verify "refs/heads/$branch" >/dev/null 2>&1; then
    if git fetch origin "$branch:$branch" 2>/dev/null; then
      echo ">> 已同步本地分支: $branch"
    else
      echo ">> 跳过同步本地 $branch（可能被当前或其他 worktree 占用）"
    fi
  fi
}

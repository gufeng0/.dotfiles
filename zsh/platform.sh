# mac
if [[ $UNAME_INFO =~ "Darwin" ]]; then
  # gnubin: intel(/usr/local) 与 arm(/opt/homebrew) 按实际存在添加
  for _gnu_dir in /usr/local/opt/coreutils/libexec/gnubin /opt/homebrew/opt/coreutils/libexec/gnubin /usr/local/opt/grep/libexec/gnubin /opt/homebrew/opt/grep/libexec/gnubin; do
    [[ -d $_gnu_dir ]] && export PATH="$_gnu_dir:$PATH"
  done
  unset _gnu_dir
  
  alias ls='ls -F --show-control-chars --color=auto'
  # eval $(gdircolors -b $HOME/.dir_colors)
  alias e='open'
  alias sed='gsed'
  alias yy='pbcopy'
  alias p='pbpaste'
  alias iterm='open -a iTerm .'
  
  export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#555555"

  # brew
  export HOMEBREW_NO_AUTO_UPDATE=true

  # iterm title bar
  # echo -en "\033]6;1;bg;red;brightness;44\a"
  # echo -en "\033]6;1;bg;green;brightness;46\a"
  # echo -en "\033]6;1;bg;blue;brightness;51\a"
  
  export PATH=$DOTFILES_DIR/bin/mac_arm64/:$PATH

elif [[ $UNAME_INFO =~ "WSL" ]]; then
  
  # windows 目录使用windows的git
  function __git_prompt_git() {
    if [[ "$PWD" =~ '^/mnt/[cdefgh]' ]]; then
      command git.exe "$@"
    else
      command git "$@"
    fi
  }
  alias git='__git_prompt_git'
  
  alias grep='grep --color'
  alias e='/mnt/c/Windows/explorer.exe'
  alias yy='win32yank.exe -i'
  alias p='win32yank.exe -o'
  alias cmd='/mnt/c/Windows/System32/cmd.exe /c'
  alias scoop='PATH=$PATH:/mnt/c/Windows/SysWOW64/WindowsPowerShell/v1.0/ /mnt/c/Users/$WIN_USER/scoop/shims/scoop'
  alias powershell='/mnt/c/Windows/SysWOW64/WindowsPowerShell/v1.0/powershell.exe'
  alias tssh='/mnt/c/Users/$WIN_USER/scoop/shims/tssh.exe'
  clippaste() {
    powershell.exe -noprofile -command Get-Clipboard | tr -d '\r'
  }
  export PATH=/mnt/c/Users/$WIN_USER/scoop/shims:$PATH
  . "$DOTFILES_DIR/win/wsl2/wezterm.sh"
elif [[ $UNAME_INFO =~ "Android" ]]; then
  alias apk-install='termux-open --view --content-type "application/vnd.android.package-archive" '
fi

if [[ $UNAME_INFO =~ "GNU/Linux" ]]; then
  arch=`arch`
  if [[ $arch =~ 'x86_64' ]]; then
    export PATH=$DOTFILES_DIR/bin/linux_x86_64:$PATH
  fi
fi

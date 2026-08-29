if [[ $UNAME_INFO =~ "microsoft" ]]; then
  : "${WINDOWS_IME_TOOLS_DIR:?WINDOWS_IME_TOOLS_DIR must be set}"
  function disable_ime_cmd {
    "$WINDOWS_IME_TOOLS_DIR/toDisableIME.exe"
  }
  function enable_ime_cmd {
    "$WINDOWS_IME_TOOLS_DIR/toDisableIME.exe"
  }
elif [[ $UNAME_INFO =~ "Darwin" ]]; then
  function disable_ime_cmd {
  }
else
  return 1
fi

vi-escape-im() {
  disable_ime_cmd
  zle vi-cmd-mode
}
zle -N vi-escape-im
bindkey "^[" vi-escape-im

# vi-insert-im() {
# $enable_ime_cmd
# zle vi-insert
# }
# zle -N vi-insert-im
# bindkey -a i vi-insert-im
#
# vi-add-eol-im() {
# $enable_ime_cmd
# zle vi-add-eol
# }
# zle -N vi-add-eol-im
# bindkey -a A vi-add-eol-im
#
# vi-insert-bol-im() {
# $enable_ime_cmd
# zle vi-insert-bol
# }
# zle -N vi-insert-bol-im
# bindkey -a I vi-insert-bol-im
#
# vi-open-line-above-im() {
# $enable_ime_cmd
# zle vi-open-line-above
# }
# zle -N vi-open-line-above-im
# bindkey -a O vi-open-line-above-im
#
# vi-open-line-below-im() {
# $enable_ime_cmd
# zle vi-open-line-below
# }
# zle -N vi-open-line-below-im
# bindkey -a o vi-open-line-below-im
#
# vi-substitute-im() {
# $enable_ime_cmd
# zle vi-substitute
# }
# zle -N vi-substitute-im
# bindkey -a s vi-substitute-im
#
# vi-change-whole-line-im() {
# $enable_ime_cmd
# zle vi-change-whole-line
# }
# zle -N vi-change-whole-line-im
# bindkey -a S vi-change-whole-line-im
#
# vi-change-eol-im() {
# $enable_ime_cmd
# zle vi-change-eol
# }
# zle -N vi-change-eol-im
# bindkey -a C vi-change-eol-im

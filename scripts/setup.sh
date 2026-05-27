#!/bin/bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

ask() {
    echo -n "$1"
    echo -n $' (y/n) \n# '
    read choice
    case $choice in
        Y | y)
        return 0
    esac
    return 1
}

link_path() {
    local src="$1"
    local dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" && ! -e "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" || -L "$dest" ]]; then
        return 0
    fi

    ln -s "$src" "$dest"
}

ask "Enable http proxy(http://127.0.0.1:1080)?" && export http_proxy=http://${HTTP_PROXY:-127.0.0.1:1080} && export https_proxy=http://${HTTP_PROXY:-127.0.0.1:1080}

if [ "$(uname)" = "Linux" ]; then
    if [ -f /etc/lsb-release ]; then
        # ask "Add add-apt-repository?" && sh "$DOTFILES_DIR/scripts/apt-ppa.sh"
        ask "Install requires(apt)?" && sh "$DOTFILES_DIR/scripts/apt-requirements.sh"
        # ask "Update nodejs?" && curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash - && sudo apt install -y nodejs
    fi
    ask "Config pip3 ali index-url?" && sh "$DOTFILES_DIR/scripts/pip3-ali.sh"
fi

link_path "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"

ask "download stardict?" && sh "$DOTFILES_DIR/scripts/download-stardict.sh"

ask "cp ~/.dotfiles/.gitconfig ~/.gitconfig?" && cp "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

ask "ln -s ~/.dotfiles/hammerspoon ~/.hammerspoon?" && link_path "$DOTFILES_DIR/hammerspoon" "$HOME/.hammerspoon"

ask "ln -s ~/.dotfiles/termux/termux.properties ~/.termux/termux.properties?" && link_path "$DOTFILES_DIR/termux/termux.properties" "$HOME/.termux/termux.properties"

ask "copy maven config?" && if [[ ! -d "$HOME/.m2" ]]; then mkdir "$HOME/.m2"; fi && cp -i "$DOTFILES_DIR/m2/settings.xml" "$HOME/.m2/settings.xml"

link_path "$DOTFILES_DIR/ideavimrc" "$HOME/.ideavimrc"
link_path "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

link_path "$DOTFILES_DIR/cheat" "$HOME/.cheat"

if [ "$(uname)" = "Darwin" ]; then
    if [[ ! -f "$HOME/.mac" ]]; then
        touch "$HOME/.mac"
    fi
fi

link_path "$DOTFILES_DIR/bin" "$HOME/.local/bin/solid"

link_path "$DOTFILES_DIR/pip/pip.conf" "$HOME/.pip/pip.conf"

# tmux
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
link_path "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# wezterm
# if [[ ! -d ~/.config/wezterm ]]; then
#     ln -s ~/.dotfiles/wezterm ~/.config/wezterm
# fi

# kitty
link_path "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# alacritty
link_path "$DOTFILES_DIR/alacritty/mac/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"

link_path "$DOTFILES_DIR/aria2/aria2.conf" "$HOME/.aria2/aria2.conf"

# nvim
link_path "$DOTFILES_DIR/vim" "$HOME/.config/nvim"

if ask "Install pip3 requirements?"; then
    sh "$DOTFILES_DIR/scripts/pip3-requirements.sh"
fi

if ask "Install npm requirements?"; then
    sh "$DOTFILES_DIR/scripts/npm-requirements.sh"
fi

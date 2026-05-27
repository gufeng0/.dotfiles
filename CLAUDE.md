# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common commands

- Initial bootstrap: `bash ~/.dotfiles/scripts/setup.sh`
- Debian/Ubuntu base packages: `bash ~/.dotfiles/scripts/install-debian-base-packages.sh`
- Additional apt packages: `bash ~/.dotfiles/scripts/apt-requirements.sh`
- Python dependencies used by editor/helpers: `bash ~/.dotfiles/scripts/pip3-requirements.sh`
- npm global tools used by editor/helpers: `bash ~/.dotfiles/scripts/npm-requirements.sh`
- Install the root Node dependency used by `vim/node/lanuagedetection.mjs`: `npm install`
- Restore Neovim plugins after plugin/lockfile changes: `bash ~/.dotfiles/lazy-restore.sh`

## Validation

- There is no repo-wide build, lint, or test script in the root `package.json`.
- No dedicated automated test suite was found.
- For Neovim plugin/config changes, the closest in-repo validation path is `bash ~/.dotfiles/lazy-restore.sh`.
- For setup changes, validate by reviewing or re-running `bash ~/.dotfiles/scripts/setup.sh` carefully, since it creates symlinks and copies files into the home directory.

## High-level architecture

- `scripts/setup.sh` is the main installer. It links this repo into the home directory (`~/.zshrc`, `~/.config/nvim`, `~/.tmux.conf`, kitty/alacritty configs, etc.) and optionally installs apt/pip/npm dependencies.
- `vim/` is the main application-like area of the repo:
  - `vim/init.lua` bootstraps `lazy.nvim` and loads the `lu5je0.*` modules.
  - `vim/lua/lu5je0/plugins.lua` is the main plugin registry/config file.
  - `vim/lua/lu5je0/ext-loader.lua` is a custom lazy-loader for in-repo features triggered by commands, keymaps, and events.
  - Most custom Neovim behavior lives under `vim/lua/lu5je0/{core,ext,misc,lang}`.
  - `vim/lua/lu5je0/options.lua` centralizes environment detection (macOS, WSL, SSH, kitty, GUI) and clipboard/IME behavior.
  - `vim/lua/lu5je0/filetype.lua` adds repo-specific filetype detection for dotfiles, tmux, SSH, and systemd configs.
  - `vim/node/lanuagedetection.mjs` is why the root `package.json` depends on `@vscode/vscode-languagedetection`.
  - `vim/snippets/` is a separate snippet manifest plus snippet JSON files.
- `zshrc` is the shell entrypoint. It bootstraps `zinit`, loads repo-local files from `zsh/`, sets aliases/functions, and enables vi-mode and Powerlevel10k.
  - `zsh/platform.sh` contains OS-specific PATH/alias branches for macOS, WSL, Android, and Linux.
  - `zsh/functions.sh` contains custom helpers and auto-activates a local `./.env` virtualenv on directory change.
- Terminal/windowing configs are split by tool:
  - `tmux/tmux.conf` defines vi-style tmux behavior and uses TPM.
  - `kitty/kitty.conf` mirrors tmux-style keybindings.
  - `hammerspoon/init.lua` handles macOS window sizing/movement.
  - `alacritty/`, `wezterm/`, `win/`, and `termux/` hold platform-specific terminal configs.
- `bin/` contains helper scripts plus checked-in per-platform binaries. `submodule/` contains standalone utilities used from wrappers such as `bin/fetch_subs`.
- `services/` contains systemd units. `ssh/config` includes `config.d/*` and GitHub-over-port-443 SSH overrides.

## Repo-specific editing notes

- Many files encode host/platform assumptions (`Darwin`, `WSL`, `/home/lu5je0`, `/Users/zm`, `~/.dotfiles`). Preserve them unless the change is specifically about portability or install behavior.
- Neovim formatting shells out to external tools; `vim/lua/lu5je0/ext-loader.lua` expects tools such as `shfmt`, `black`, `prettier`, `sql-formatter`, and `xmllint`.
- Lua formatting preferences live in `vim/stylua.toml`.
- If you change Neovim plugin declarations or lock state, `lazy-restore.sh` is the checked-in recovery path.
- Files under `services/` are host-specific operational configs, not general-purpose library code.

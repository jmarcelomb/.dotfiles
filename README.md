## 👋🏻 Welcome to my .dotfiles `rabbit hole`!

This is where I'm always tweaking and changing something to have my config feeling like home.

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/jmarcelomb/.dotfiles/main.svg)](https://results.pre-commit.ci/latest/github/jmarcelomb/.dotfiles/main)

---

## 🚀 Quick Setup

<details>
<summary>Click to expand setup instructions</summary>

Clone the repository and initialize submodules:

```sh
git clone https://github.com/jmarcelomb/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

For **macOS** systems:

```sh
nix run nix-darwin/master#darwin-rebuild -- switch --flake .#mac-mini
```

For **NixOS** systems:

```sh
sudo nixos-rebuild switch --flake .#konoha
```

For **server configurations** (chakra):

```sh
sudo nixos-rebuild switch --flake .#chakra
```

</details>

---

## ⚡ CLI Tools

### Core Terminal Tools

- [fish](https://github.com/fish-shell/fish-shell) - Smart and user-friendly command line shell with syntax highlighting and autocompletions.
- [starship](https://github.com/starship/starship) - Fast, customizable prompt for any shell with custom duck icon for Yazi subshells.
- [fzf](https://github.com/junegunn/fzf) - A general-purpose command-line fuzzy finder.
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer with comprehensive configuration, TPM plugin management, and AI integration.
- [bat](https://github.com/sharkdp/bat) - A `cat` clone with syntax highlighting.
- [eza](https://github.com/eza-community/eza) - A modern replacement for `ls`.
- [zoxide](https://github.com/ajeetdsouza/zoxide) - A smarter `cd` command.
- [direnv](https://github.com/direnv/direnv) - Loads and unload environment variables depending on the current directory.
- [fd](https://github.com/sharkdp/fd) - A fast, user-friendly alternative to `find`.
- [ripgrep](https://github.com/BurntSushi/ripgrep) - A fast regex-based search tool.
- [bottom](https://github.com/ClementTsang/bottom) - A cross-platform system monitor.
- [git-delta](https://github.com/dandavison/delta) - A syntax-highlighting pager for Git.
- [typos-cli](https://github.com/crate-ci/typos) - A source code spell checker.
- [du-dust](https://github.com/bootandy/dust) - A more intuitive version of `du`.
- [dysk](https://github.com/Canop/dysk) - A linux utility to get information on filesystems, like df but better.

### File Management & Editors

- [yazi](https://github.com/sxyazi/yazi) - A terminal file manager written in Rust with extensive plugin support.
- [neovim](https://github.com/neovim/neovim) - Hyperextensible Vim-based text editor using [LazyVim](https://www.lazyvim.org/) as base with custom plugins (see [configuration](https://github.com/jmarcelomb/nvim)).
- [lazygit](https://github.com/jesseduffield/lazygit) - A simple terminal UI for Git.

### Terminal Emulators

- [ghostty](https://github.com/ghostty-org/ghostty) - Fast, feature-rich, and cross-platform terminal emulator (currently using).
- [kitty](https://github.com/kovidgoyal/kitty) - Cross-platform, fast, feature-rich, GPU-based terminal emulator (previously used).
- [alacritty](https://github.com/alacritty/alacritty) - GPU-accelerated terminal emulator (previously used).

### macOS Window Management

- [aerospace](https://github.com/nikitabobko/AeroSpace) - i3-like tiling window manager for macOS.
- [sketchybar](https://github.com/FelixKratz/SketchyBar) - A highly customizable macOS status bar replacement.

### AI & Development Tools

- [crush](https://crush.ninja/) - AI-powered CLI tool with GitHub Copilot integration.
- [uv](https://astral.sh/uv/) - An extremely fast Python package installer and resolver.

### Handy Scripts

- [ask](./scripts/ask) - AI-powered question answering using [llm](https://github.com/simonw/llm) under the hood.
- [ask.fish](./.config/fish/functions/ask.fish) - Fish shell function for interactive AI conversations with clipboard integration.
- [gen_commit_msg](./scripts/gen_commit_msg) - Generates intelligent conventional commit messages using the ask script.
- [copy](./scripts/copy) - Puts stdin in the OSC52 register.
- [paste](./scripts/paste) - Opens a text input for pasting.
- [lpaste](./scripts/lpaste) - Outputs the last text input from `paste`.
- [git-clone-bare-for-worktrees](./scripts/git-clone-bare-for-worktrees) - Clone repositories using bare repos for Git worktrees.

### Tools I'm keeping an eye on 👀

- [television](https://github.com/alexpasmantier/television) - A blazingly fast general purpose fuzzy finder TUI.
- [zellij](https://github.com/zellij-org/zellij) - A terminal workspace with batteries included (previously used, now using tmux).
- [gitui](https://github.com/extrawurst/gitui) - Blazing fast terminal-ui for Git (complementary to lazygit).
- [helix](https://github.com/helix-editor/helix) - A modal text editor with built-in LSP support.
- [skim](https://github.com/skim-rs/skim) - Fuzzy finder in Rust.
- [tabiew](https://github.com/shshemi/tabiew) - A lightweight TUI application to view and query CSV files.
- [gpg-tui](https://github.com/orhun/gpg-tui) - Manage your GnuPG keys with ease.

---

## 🎨 Configuration Highlights

### Nix & Home Manager

This setup uses [Nix](https://nixos.org/) with [Home Manager](https://github.com/nix-community/home-manager) for declarative system and user environment management:

- **Cross-platform**: Supports macOS (nix-darwin), NixOS, and server configurations
- **Modular structure**: Host-specific configurations with shared common packages
- **Automated updates**: Auto-upgrade modules for server environments
- **Reproducible**: Consistent environment across all machines

### Terminal Experience

- **Fish Shell** with enhanced completions, AI integration via `ask` function, and clipboard utilities
- **Starship** prompt with custom duck icon for Yazi subshells
- **Tmux** as primary multiplexer with Catppuccin theme, TPM plugin management, AI selection support, and sesh session management
- **Yazi** file manager with comprehensive plugin ecosystem (git, chmod, starship, lazygit, smart-paste, toggle-pane, fr search)

### macOS Integration

- **AeroSpace** tiling window manager with workspace automation
- **SketchyBar** status bar with workspace indicators and system info
- **Homebrew** cask management for GUI applications
- **System defaults** configuration for optimal developer experience

---

## 💻 Shell Setup

I currently use [fish](https://fishshell.com/) and Bash/Zsh with the [Starship](https://starship.rs/) prompt.

### How to set Fish as the Default Shell

```sh
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

### Install Starship Prompt

Install [Starship](https://starship.rs/) for a modern, customizable shell prompt:

```sh
curl -sS https://starship.rs/install.sh | sh
```

### How to set Zsh as the Default Shell

```sh
chsh -s $(which zsh)
```

---

## 🦀 Rust Setup

### Install Rust

Install Rust using Rustup:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

---

## 🐍 Python Setup

### Install `uv`

Use [uv](https://astral.sh/uv/) to manage Python virtual environments and projects:

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Or install via Cargo:

```sh
cargo install --git https://github.com/astral-sh/uv uv
```

---

## 🦀 Alternative: Manual Rust Tools Installation

If you prefer to install Rust tools manually instead of using Nix/Home Manager:

### Installing Rust Tools via Cargo

```sh
cargo install bat \
              eza \
              zoxide \
              fd-find \
              ripgrep \
              yazi-build \
              bottom \
              git-delta \
              typos-cli \
              du-dust \
              dysk
```

### Rust Toolchain Management

#### cargo-update

[cargo-update](https://github.com/nabijaczleweli/cargo-update) helps keep installed Rust tools up to date:

```sh
cargo install cargo-update
cargo install-update -a  # Update all installed programs
```

#### cargo-binstall

[cargo-binstall](https://github.com/cargo-bins/cargo-binstall) installs prebuilt binaries instead of compiling from source:

```sh
cargo install cargo-binstall
cargo binstall <package-name>  # Much faster installation
```

---

## 📝 Notes

- This repository is tailored to my personal development workflow but can be adapted for others.
- Contributions and suggestions are always welcome!

---

### 🌟 Feedback

If you have ideas for improvement, feel free to open an issue or a pull request on [GitHub](https://github.com/jmarcelomb/.dotfiles).

_version:_ v1.0.0 <!-- x-release-please-version -->

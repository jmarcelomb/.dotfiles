# .dotfiles

👋🏻 Welcome to my `.dotfiles` repository

This setup is designed to streamline the configuration of my development environment,
including my shell, programming languages, and essential CLI tools.

<!--toc:start-->
- [.dotfiles](#dotfiles)
  - [🚀 Quick Setup](#🚀-quick-setup)
  - [💻 Shell Setup](#💻-shell-setup)
    - [Set Fish as the Default Shell](#set-fish-as-the-default-shell)
    - [Install Starship Prompt](#install-starship-prompt)
    - [Set Zsh as the Default Shell](#set-zsh-as-the-default-shell)
  - [🦀 Rust Setup](#🦀-rust-setup)
  - [🐍 Python Setup](#🐍-python-setup)
    - [Install `uv`](#install-uv)
  - [⚡ Essential CLI Tools](#essential-cli-tools)
    - [Handy scripts:](#handy-scripts)
    - [Tools I'm keeping an eye on 👀:](#tools-im-keeping-an-eye-on-👀)
    - [Alacritty](#alacritty)
    - [cargo-update](#cargo-update)
    - [cargo-binstall](#cargo-binstall)
  - [📝 Notes](#📝-notes)
    - [🌟 Feedback](#🌟-feedback)
<!--toc:end-->

---

## 🚀 Quick Setup

Clone the repository and initialize submodules:

```sh
git clone https://github.com/jmarcelomb/.dotfiles.git
cd .dotfiles
./setup.sh
```

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

## ⚡ Essential CLI Tools

Tools I currently use:

- [zellij](https://github.com/zellij-org/zellij) - A terminal workspace with batteries included.
- [bat](https://github.com/sharkdp/bat) - A `cat` clone with syntax highlighting.
- [eza](https://github.com/eza-community/eza) - A modern replacement for `ls`.
- [zoxide](https://github.com/ajeetdsouza/zoxide) - A smarter `cd` command.
- [fd](https://github.com/sharkdp/fd) - A fast, user-friendly alternative to `find`.
- [ripgrep](https://github.com/BurntSushi/ripgrep) - A fast regex-based search tool.
- [yazi](https://github.com/sxyazi/yazi) - A terminal file manager written in Rust.
- [bottom](https://github.com/ClementTsang/bottom) - A cross-platform system monitor.
- [git-delta](https://github.com/dandavison/delta) - A syntax-highlighting pager for Git.
- [typos-cli](https://github.com/crate-ci/typos) - A source code spell checker.
- [du-dust](https://github.com/bootandy/dust) - A more intuitive version of `du`.
- [lazygit](https://github.com/jesseduffield/lazygit) - A simple terminal UI for Git.

### Handy scripts:

- [copy](./scripts/copy) - Puts stdin in the OSC52 register.
- [paste](./scripts/paste) - Opens a text input for pasting.
- [lpaste](./scripts/lpaste) - Outputs the last text input from `paste`.
- [gen_commit_msg](./scripts/gen_commit_msg) - Uses local [Ollama](https://ollama.com/) or generate to standard output commit messages from `git diff`.

### Tools I'm keeping an eye on 👀:

- [television](https://github.com/alexpasmantier/television)
- [tabiew](https://github.com/shshemi/tabiew)
- [gitui](https://github.com/extrawurst/gitui)
- [gpg-tui](https://github.com/orhun/gpg-tui)

It is possible to install all current Rust tools via Cargo:

```sh
cargo install zellij \
              bat \
              eza \
              zoxide \
              fd-find \
              ripgrep \
              yazi-fm yazi-cli \
              bottom \
              git-delta \
              typos-cli \
              du-dust
```

---

### Alacritty

```sh
cargo install alacritty
```

### cargo-update

[cargo-update](https://github.com/nabijaczleweli/cargo-update) helps keep installed Rust tools up to date.

Install it via Cargo:

```sh
cargo install cargo-update
```

Update all installed Rust programs:

```sh
cargo install-update -a
```

### cargo-binstall

If you prefer not to compile Rust programs from source, [cargo-binstall](https://github.com/cargo-bins/cargo-binstall) installs prebuilt binaries.

Example:

```sh
cargo binstall zellij
```

Install it via Cargo:

```sh
cargo install cargo-binstall
```

I'm still testing it out, but [gitui](https://github.com/extrawurst/gitui) could be a potential `lazygit` replacement, making it possible to install almost everything using Cargo:

```sh
cargo install gitui
```

---

## 📝 Notes

- This repository is tailored to my personal development workflow but can be adapted for others.
- Contributions and suggestions are always welcome!

---

### 🌟 Feedback

If you have ideas for improvement, feel free to open an issue or a pull request on [GitHub](https://github.com/jmarcelomb/.dotfiles).

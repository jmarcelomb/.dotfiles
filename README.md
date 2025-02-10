# .dotfiles

Welcome to my `.dotfiles` repository!
This setup is designed to streamline the configuration of my development environment,
including shell, programming languages, and essential CLI tools.

<!--toc:start-->
- [.dotfiles](#dotfiles)
  - [🚀 Quick Setup](#🚀-quick-setup)
  - [💻 Shell Setup](#💻-shell-setup)
    - [Install zsh](#install-zsh)
    - [Install Starship Prompt](#install-starship-prompt)
    - [Set Zsh as Default Shell](#set-zsh-as-default-shell)
  - [🦀 Rust Setup](#🦀-rust-setup)
  - [🐍 Python Setup](#🐍-python-setup)
    - [Install `uv`](#install-uv)
  - [⚡ Essential CLI Tools](#essential-cli-tools)
  - [🔧 Additional (Not Actively Used)](#🔧-additional-not-actively-used)
    - [TMux](#tmux)
    - [i3 Window Manager](#i3-window-manager)
  - [📝 Notes](#📝-notes)
    - [🌟 Feedback](#🌟-feedback)
<!--toc:end-->

---

## 🚀 Quick Setup

Clone the repository and initialize submodules:

```sh
git clone https://github.com/jmarcelomb/.dotfiles.git
cd .dotfiles
git submodule update --init --recursive
./setup.sh
```

---

## 💻 Shell Setup

Currently I'm using [fish](https://fishshell.com/) and zsh shells with (starship.rs)[starship.rs] prompt.

### How to install zsh

Ubuntu:

```sh
sudo apt install git zsh -y
```

### How to install fish

Ubuntu:

```sh
sudo apt install fish -y
```
### How to set fish as Default Shell

```sh
echo $(which fish) | sudo tee -a /etc/shells
chsh -s $(which fish)
```

### Install Starship Prompt

Install [Starship](https://starship.rs/) for a modern shell prompt:

```sh
curl -sS https://starship.rs/install.sh | sh
```

### How to set Zsh as Default Shell

Change your default shell to Zsh:

```sh
chsh -s $(which zsh)
```

For users starting Zsh from Bash, ensure `.bashrc` switches to Zsh:

```sh
echo "exec zsh" > ~/.bashrc
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

Use [uv](https://astral.sh/uv/) to manage Python virtual environments:

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Or using cargo:

```sh
cargo install --git https://github.com/astral-sh/uv uv
```

---

## ⚡ Essential CLI Tools

Install useful CLI utilities via Cargo:

```sh
cargo install zellij bat eza zoxide fd-find ripgrep du-dust bottom git-delta typos-cli yazi-fm yazi-cli
```

### Alacritty

```sh
cargo install alacritty
```

### [cargo-update](https://github.com/nabijaczleweli/cargo-update):

You can use [cargo-update](https://github.com/nabijaczleweli/cargo-update) to update the installed programs. You can install it using cargo:

```sh
cargo install cargo-update
```

And then to update all programs do:

```sh
cargo install-update -a
```

### [cargo-binstall](https://github.com/cargo-bins/cargo-binstall)

If you don't want to install compile the rust programs you can use [cargo-binstall](https://github.com/cargo-bins/cargo-binstall) to install only the binary of the respective program.

Example:
```sh
cargo binstall zellij
```

You can install it using cargo:

```sh
cargo install cargo-binstall
```

### Alternative to [lazygit](https://github.com/jesseduffield/lazygit)

I'm still trying it out, but we can use the [gitui](https://github.com/extrawurst/gitui) rust program to replace lazygit so we can install almost all tools using cargo.

```sh
cargo install gitui
```

### Yazi

Install theme:

```sh
ya pack -a dangooddd/kanagawa
```

---

## 🔧 Additional (Not Actively Used)

### TMux

For terminal multiplexing, you can use `TMux`:

```sh
sudo apt-get install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### i3 Window Manager

To install **i3** and its configuration tools:

```sh
sudo apt-get install lxappearance
```

---

## 📝 Notes

- This repository is tailored to my personal development workflow but can be
adapted for others.
- Contributions and suggestions for improvements are welcome!

---

### 🌟 Feedback

Feel free to raise issues or open pull requests on [GitHub](https://github.com/jmarcelomb/.dotfiles).
Let's make this setup even better together!

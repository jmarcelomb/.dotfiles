# Uraraka

## How to setup:

# Submodule init

```sh
git submodule update --init --recursive

```

```sh
sudo apt-get install stow
stow .
```

## Useful commands:

## How to install zshrc shell:

```sh
sudo apt install git zsh -y
```

### ~~OMZ (not used)~~

```sh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

### Startship.rs

```sh
curl -sS https://starship.rs/install.sh | sh
```

### Set default shell

Set default as default shell:

```sh
chsh -s $(which zsh)
```

```sh
echo "exec zsh" > ~/.bashrc
```

## tmux:

### Install:

```sh
sudo apt-get install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## Rust

### Install:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## i3m:

```sh
sudo apt-get install lxappearance
```

## Python

### uv

```sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## CLI tools

### bat

```sh
cargo install bat
```

### fzf

```sh
brew install fzf
```

### fd

```sh
brew install fd
```

# Uraraka

## How to setup:

```sh
sudo apt-get install stow
stow
```

## Useful commands:

## How to install zshrc shell:
```sh
sudo apt install git zsh -y
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

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

### Configure oh-my-tmux

```sh
ln -s -f .tmux/.tmux.conf
cp .tmux/.tmux.conf.local .
```


### i3m:

```sh
sudo apt-get install lxappearance
```
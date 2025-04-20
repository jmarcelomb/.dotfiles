{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    firefox

    # CLI utils
    bc
    wget
    curl
    zip
    unzip
    git
    zsh

    fzf
    zoxide
    zellij
    yazi
    glow
    imagemagick
    ripgrep
    direnv
    fd
    bat
    typos
    typos-lsp
    bottom
    dust
    delta
    gitui
    lazygit

    alacritty
    kitty

    # Coding stuff
    vscode
    python311
    rust-bin.stable.latest.default
    gcc
    gnumake
    nodejs_23
  ];
}

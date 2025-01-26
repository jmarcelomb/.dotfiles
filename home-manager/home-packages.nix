{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    firefox

    # CLI utils
    bc
    htop
    unzip
    wget
    curl
    wl-clipboard
    zip
    git
    zsh
    ghostty

    fzf
    alacritty
    zoxide
    zellij
    yazi
    ripgrep
    direnv
    fd
    typos
    typos-lsp
    bottom
    dust
    delta
    gitui
    lazygit

    # Coding stuff
    python311
    cargo
    gcc
  ];
}

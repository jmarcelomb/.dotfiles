{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

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

    # Coding stuff
    python311
    cargo
    gcc
  ];
}

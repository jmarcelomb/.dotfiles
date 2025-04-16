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
    typos
    typos-lsp
    bottom
    dust
    delta
    gitui
    lazygit

    # Coding stuff
    vscode
    python311
    cargo
    gcc
    gnumake
    nodejs_23
  ];
}

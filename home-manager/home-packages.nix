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
    ripgrep
    fzf
    yazi
    zellij
    neovim
    git

    # Coding stuff
    python311
    gcc
  ];
}

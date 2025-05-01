{ pkgs, isServer, ... }: {
  nixpkgs.config.allowUnfree = true;

  # Define package groups
  home.packages = with pkgs; let
    cliUtils = [
      bc
      wget
      curl
      zip
      unzip
      git
      zsh
      fzf
      zoxide
      ripgrep
      direnv
      fd
      bat
      bottom
      dust
      delta
      yazi
    ];

    serverUtils = [
    ];

    devTools = [
      firefox

      vscode
      python311
      rust-bin.stable.latest.default
      bacon
      gcc
      gnumake
      nodejs_23

      alacritty
      kitty

      imagemagick
      glow

      gitui
      lazygit

      typos
      typos-lsp
    ];

    miscTools = [
      zellij
    ];
  in
    cliUtils
    ++ miscTools
    ++ (if isServer then serverUtils else devTools);
}

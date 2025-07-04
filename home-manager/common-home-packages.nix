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

      helix
    ];

    serverUtils = [
    ];

    devTools = [
      firefox

      vscode
      python311
      uv
      rust-bin.stable.latest.default
      rust-analyzer
      bacon
      gcc
      lldb
      gnumake
      nodejs_24
      zig

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

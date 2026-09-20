{ pkgs, isServer, ... }: {
  nixpkgs.config.allowUnfree = true;

  # Define package groups
  home.packages = with pkgs; let
    # Core CLI utilities (available everywhere)
    cliUtils = [
      # System utilities
      coreutils
      gnused
      gawk
      bc

      # Network tools
      wget
      curl

      # Archive tools
      zip
      unzip

      # Version control
      git
      lazygit

      # Shell & navigation
      zsh
      fzf
      atuin
      zoxide
      direnv

      # Modern CLI tools
      ripgrep
      fd
      bat
      bottom
      dust
      delta
      yazi

      # Editor
      # helix

     (pkgs.ffmpeg-full.override { withUnfree = true; })
    ];

    miscTools = [
      tmux
      zellij
      sesh
    ];

    # Server-specific utilities
    serverUtils = [
    ];

    # Development tools (dev machines only)
    devTools = [
      # GUI applications
      # firefox
      # alacritty
      # kitty
      # opencloud-desktop

      # Programming languages & toolchains
      # python311
      uv
      rust-bin.stable.latest.default
      rust-analyzer
      # nodejs_22
      # pnpm
      zig
      go

      # Compilers & build tools
      gcc
      lldb
      gnumake

      # Dev utilities & testing
      bacon
      hyperfine
      typos
      typos-lsp

      # Dev workflow tools
      lazydocker

      # Data & document tools
      tabiew
      glow
      # imagemagick
    ];
  in
    cliUtils
    ++ miscTools
    ++ (if isServer then serverUtils else devTools);
}

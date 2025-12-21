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
      helix
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
      firefox
      alacritty
      kitty

      # Programming languages & toolchains
      python311
      uv
      rust-bin.stable.latest.default
      rust-analyzer
      nodejs_22
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
      lazygit
      lazydocker

      # Data & document tools
      tabiew
      glow
      imagemagick
    ];
  in
    cliUtils
    ++ miscTools
    ++ (if isServer then serverUtils else devTools);
}

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
      jq

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
      # Terminal emulators (lightweight, don't need GPU offload)
      alacritty
      kitty

      # Note-taking (lightweight GUI app)
      joplin-desktop

      # Cloud storage
      opencloud-desktop

      # GPU-intensive GUI apps moved to system packages per-host
      # (see hosts/*/configuration.nix for zen-browser, vlc, spotify, etc.)

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

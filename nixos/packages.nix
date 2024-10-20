{ pkgs, ... }: {
  nixpkgs.config = {
    allowUnfree = true;
    # permittedInsecurePackages = ["python-2.7.18.8" "electron-25.9.0"];
  };

  environment.systemPackages = with pkgs; [
    # Desktop apps
    chromium
    alacritty
    obs-studio
    gparted
    vscode

    # Coding stuff
    gnumake
    gcc
    (python3.withPackages (ps: with ps; [ requests ]))

    # CLI utils
    neovim
    file
    tree
    wget
    curl
    git
    fastfetch
    htop
    nix-index
    unzip
    zip
    openssl

    # Xorg stuff
    #xterm
    xclip
    #xorg.xbacklight

    # Wayland stuff
    # xwayland
    # wl-clipboard
    # cliphist

    # WMs and stuff
    # herbstluftwm
    # hyprland
    # seatd
    # xdg-desktop-portal-hyprland
    # polybar
    # waybar

    # Sound
    pipewire
    pulseaudio
    pamixer

    # GPU stuff 
    amdvlk
    rocm-opencl-icd
    glaxnimate

    # Screenshotting
    # grim
    # grimblast
    # slurp
    # flameshot
    # swappy

    # Other
    home-manager
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    noto-fonts
    noto-fonts-emoji
    twemoji-color-font
    font-awesome
    powerline-fonts
    powerline-symbols
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}

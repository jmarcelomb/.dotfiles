{ pkgs, user, ... }: {
  programs.zsh.enable = true;
  programs.fish.enable = true;

  programs.nix-ld.enable = true;

  users = {
    defaultUserShell = pkgs.fish;
    users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  services.getty.autologinUser = user;
}

{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    dbeaver-bin
    gnupg
  ];
}

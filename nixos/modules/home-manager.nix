{ inputs, pkgs, ... }: {
  imports = [ inputs.home-manager.nixosModules.default ];

  # Custom backup command that overwrites old .backup files
  home-manager.backupFileExtension = null;
  home-manager.backupCommand = ''
    ${pkgs.bash}/bin/bash -c 'if [ -e "$1" ]; then ${pkgs.coreutils}/bin/mv -f "$1" "$1.backup"; fi' --
  '';
}

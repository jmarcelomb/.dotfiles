{ pkgs, stateVersion, hostname, user, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix
    ./ssh.nix
    ../../nixos/modules/default.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = stateVersion;

  # Host-specific settings
  virtualisation.vmware.guest.enable = true;

  systemd.services.mount-vmhgfs = {
    description = "Mount VMware Shared Folders";
    after = [ "network.target" "open-vm-tools.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.open-vm-tools}/bin/vmhgfs-fuse .host:/ /mnt/hgfs -o subtype=vmhgfs-fuse,allow_other";
      ExecStop = "${pkgs.util-linux}/bin/umount /mnt/hgfs";
      RemainAfterExit = true;
    };
  };

  system.activationScripts.mkHGFSDir = ''
    mkdir -p /mnt/hgfs
  '';
}

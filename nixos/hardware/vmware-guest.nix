# VMware guest tools and optimizations
# For NixOS running inside VMware
{ pkgs, ... }:

{
  # Enable VMware guest tools
  virtualisation.vmware.guest.enable = true;

  # Mount VMware Shared Folders
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

  # Create mount point
  system.activationScripts.mkHGFSDir = ''
    mkdir -p /mnt/hgfs
  '';

  # VM-specific optimizations for Wayland/Sway
  environment.variables = {
    # Disable hardware cursors for better VMware compatibility
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}

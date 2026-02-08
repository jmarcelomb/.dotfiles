# NFS client configuration with flexible mount support
# Can be used in two ways:
#
# 1. Simple: Just enable NFS client support (mount in host config)
#    imports = [ ../../nixos/hardware/nfs-client.nix ];
#
# 2. With mounts: Pass mounts as arguments (use helper function)
#    imports = [
#      (nfsWithMounts [
#        { path = "/mnt/media"; server = "nas.local:/media"; }
#        { path = "/mnt/backups"; server = "nas.local:/backups"; options = [ "ro" ]; }
#      ])
#    ];

{ lib, config, ... }:

{
  options = {
    # No options needed for simple case
  };

  config = {
    # Always enable NFS client support
    services.rpcbind.enable = true;
  };
}

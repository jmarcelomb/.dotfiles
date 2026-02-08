# NFS with mounts helper
# Usage in host config:
#   imports = [
#     (import ../../nixos/hardware/nfs-with-mounts.nix {
#       mounts = [
#         { path = "/mnt/media"; server = "nas.local:/media"; }
#         { path = "/mnt/backups"; server = "nas.local:/backups"; options = [ "ro" ]; }
#       ];
#     })
#   ];

{ mounts }:

{ lib, ... }:

let
  # Helper to create a filesystem entry
  mkNfsMount = mount: {
    name = mount.path;
    value = {
      device = mount.server;
      fsType = "nfs";
      options = mount.options or [ "nfsvers=4" "rw" "soft" "intr" ];
    };
  };
in
{
  # Enable NFS client support
  services.rpcbind.enable = true;

  # Create filesystem mounts
  fileSystems = lib.listToAttrs (map mkNfsMount mounts);
}

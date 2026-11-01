# Fluxer - self-hosted Fluxer chat VM (rexctl-managed)
#
# Cloned from chakra's disk (TrueNAS vm.clone), so hardware-configuration.nix
# carries chakra's UUIDs: they are correct for this VM's own zvols.
{
  pkgs,
  lib,
  stateVersion,
  hostname,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix

    # Shared NixOS modules. Audio/bluetooth/gnome/mime/gpg are intentionally
    # NOT imported because fluxer is a headless server VM.
    ../../nixos/modules/boot.nix
    ../../nixos/modules/docker.nix
    ../../nixos/modules/env.nix
    ../../nixos/modules/net.nix
    ../../nixos/modules/nix.nix
    ../../nixos/modules/timezone.nix
    ../../nixos/modules/user.nix

    # NetBird peer so the NetBird reverse proxy can target this VM.
    ./modules/netbird.nix

    # Nightly backup of the Fluxer instance shipped to TrueNAS (HDD pool).
    ./modules/backups.nix
  ];

  networking.hostName = hostname;
  system.stateVersion = stateVersion;

  # Headless server: no getty autologin (overrides the shared default).
  services.getty.autologinUser = lib.mkForce null;

  services.openssh.enable = true;

  # QEMU guest agent lets TrueNAS do graceful shutdowns via ACPI + agent hooks
  # instead of hard-killing the VM.
  services.qemuGuest.enable = true;

  # Cap the journal so it can't grow unbounded on a small root fs.
  services.journald.settings.Journal = {
    SystemMaxUse = "500M";
    SystemKeepFree = "1G";
  };

  # Compressed RAM swap in addition to the existing disk swap partition.
  # zram is preferred (higher priority) because it's much faster and avoids
  # write amplification on the ZFS zvol; the disk swap remains as a fallback
  # if zram fills up (e.g. during a large nixos-rebuild).
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };

  # NFS backup share from TrueNAS (HDD pool). `x-systemd.automount` mounts
  # on first access so a TrueNAS outage doesn't block VM boot. Same pattern
  # as chakra's /mnt/nfs-chakra.
  fileSystems."/mnt/nfs-fluxer" = {
    device = "truenas.home:/mnt/nas/fluxer";
    fsType = "nfs";
    options = [
      "nfsvers=4"
      "rw"
      "soft"
      "timeo=100"
      "retrans=3"
      "x-systemd.automount"
      "x-systemd.mount-timeout=30"
      "noauto"
    ];
  };
}

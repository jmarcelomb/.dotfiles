# Chakra - Headless server system
{ pkgs, lib, stateVersion, hostname, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix

    # Shared NixOS modules. Audio/bluetooth/gnome/mime/gpg are intentionally
    # NOT imported because chakra is a headless server VM.
    ../../nixos/modules/boot.nix
    ../../nixos/modules/docker.nix
    ../../nixos/modules/env.nix
    ../../nixos/modules/net.nix
    ../../nixos/modules/nix.nix
    ../../nixos/modules/timezone.nix
    ../../nixos/modules/user.nix

    ./modules/backups.nix
    ./modules/netbird-stack.nix
    #(import ./modules/auto-upgrade.nix { inherit inputs; })
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
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemKeepFree=1G
  '';

  # Compressed RAM swap in addition to the existing disk swap partition.
  # zram is preferred (higher priority) because it's much faster and avoids
  # write amplification on the ZFS zvol; the disk swap remains as a fallback
  # if zram fills up (e.g. during a large nixos-rebuild).
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 100;
  };

  # NFS client support.
  services.rpcbind.enable = true;

  # NFS backup share from TrueNAS. `x-systemd.automount` mounts on first
  # access so a TrueNAS outage doesn't block VM boot. Once mounted it stays
  # mounted (no idle timeout) so the nightly backup timer never hits a cold
  # automount delay.
  fileSystems."/mnt/nfs-chakra" = {
    device = "truenas.home:/mnt/nas/chakra";
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

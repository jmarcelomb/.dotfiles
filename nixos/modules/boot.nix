{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Clear /tmp on every boot so it doesnt accumulate across reboots.
  boot.tmp.cleanOnBoot = true;
}

# Standard systemd-boot bootloader configuration
# Used by most modern UEFI systems
_:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}

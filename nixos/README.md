# NixOS Configuration Structure

This directory contains modular NixOS configurations that are easy to understand, upgrade, and reuse.

## Directory Structure

```
nixos/
├── profiles/          # Mix-and-match system profiles
│   ├── base.nix      # Core config (required for all hosts)
│   ├── desktop.nix   # Desktop environment (Sway, audio, bluetooth)
│   └── server.nix    # Server config (headless, SSH, Docker)
├── hardware/         # Hardware-specific modules
│   ├── bootloader.nix    # Standard systemd-boot setup
│   ├── vmware-guest.nix  # VMware tools and optimizations
│   └── nfs-client.nix    # NFS client support
└── modules/          # Individual feature modules
    ├── sway.nix      # Sway window manager
    ├── audio.nix     # PipeWire audio
    ├── bluetooth.nix # Bluetooth support
    └── ...           # Other modules
```

## Profiles

### base.nix (Required)
Core NixOS configuration that all hosts need:
- Hostname, timezone, locale
- Nix flakes and garbage collection
- Essential packages: git, neovim, wget, curl
- User configuration
- Sudo setup

### desktop.nix
For graphical desktop systems:
- Sway window manager
- Audio (PipeWire)
- Bluetooth
- Desktop applications (Vicinae, Nautilus)
- Printing support

### server.nix
For headless server systems:
- SSH server
- Docker
- Server monitoring tools (bottom, iotop)
- No GUI components

## Hardware Modules

### bootloader.nix
Standard UEFI systemd-boot configuration. Used by most modern systems.

### vmware-guest.nix
For NixOS running inside VMware:
- VMware guest tools
- Shared folders mounting
- Wayland optimizations (disables hardware cursors)

### nfs-client.nix
Enables NFS client support for mounting network shares.

## Host Configuration Examples

### Desktop Host (byakugan)
```nix
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/hardware/bootloader.nix
    ../../nixos/profiles/base.nix
    ../../nixos/profiles/desktop.nix
  ];
}
```

### VM Desktop Host (konoha)
```nix
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/hardware/bootloader.nix
    ../../nixos/hardware/vmware-guest.nix
    ../../nixos/profiles/base.nix
    ../../nixos/profiles/desktop.nix
  ];
}
```

### Server Host (chakra)
```nix
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/hardware/bootloader.nix
    ../../nixos/hardware/nfs-client.nix
    ../../nixos/profiles/base.nix
    ../../nixos/profiles/server.nix
  ];

  # Host-specific NFS mount
  fileSystems."/mnt/nfs-chakra" = {
    device = "truenas.home:/mnt/nas/chakra";
    fsType = "nfs";
    options = [ "nfsvers=4" "rw" "soft" "intr" ];
  };
}
```

## Adding a New Host

1. Create host directory: `hosts/newhostname/`
2. Generate hardware config: `nixos-generate-config --root /mnt --show-hardware-config > hosts/newhostname/hardware-configuration.nix`
3. Create minimal `configuration.nix` with appropriate profiles
4. Add to `flake.nix` nixosConfigurations

## Philosophy

- **Profiles** = Composable system configurations (base + desktop/server)
- **Hardware modules** = Hardware-specific settings (bootloader, vmware, nfs)
- **Feature modules** = Individual features (sway, audio, bluetooth)
- **Host configs** = Just imports + host-specific settings (10-30 lines)

This keeps configurations:
- **DRY** - No duplication
- **Clear** - Easy to understand what each host has
- **Reusable** - Mix and match profiles for new hosts
- **Maintainable** - Update once, applies everywhere

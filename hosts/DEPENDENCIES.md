# Host & External Dependency Map

Everything that connects the six hosts to each other and to infrastructure
OUTSIDE this flake. If you change any piece mentioned here, check the
arrows. (Verified 2026-10-04; keep updated.)

## Fleet

| Host | What | Addr | Notes |
|---|---|---|---|
| mac-mini | aarch64-darwin, daily driver | this machine | keystone: hosts konoha VM, receives chakra backups |
| konoha | aarch64-linux sway desktop VM (VMware Fusion on mac-mini) | 192.168.0.231 | often off; shares `~/Virtual Machines.localized/Share` ↔ `/mnt/hgfs` |
| chakra | x86_64-linux server VM on TrueNAS | 192.168.0.236 | docker stacks from `~/server` (separate repo `jmarcelomb/server`) |
| caddy | x86_64-linux VM (chakra clone) | 192.168.0.237 | reverse proxy + netbird client only |
| byakugan | x86_64-linux sway laptop | 192.168.0.104 | holds the GPG commit-signing key (`includeIf hostname:byakugan`) |

## Cross-host contracts

- **chakra -> mac-mini (nightly offsite rsync, 20:00)**: authenticates with
  `/home/hinata/.ssh/id_ed25519_backup`; mac-mini's authorized_keys pins it
  with `command="..." restrict from="192.168.0.236"`. **chakra's IP is a
  contract enforced on mac-mini but assigned outside the flake** (router/
  TrueNAS DHCP). Re-IP chakra and the offsite backup dies silently (the
  NFS backup keeps working - half-healthy, easy to miss).
- **caddy -> chakra (nightly state push, 01:15)**: `hosts/caddy/modules/backups.nix`
  rsyncs caddy/netbird volumes into chakra's `~/server/volumes/caddy-guest/`
  so chakra's own backups carry them to TrueNAS + mac-mini.
- **caddy VM -> chakra netbird server**: `NB_MANAGEMENT_URL` =
  `https://netbird.marceloborges.dev` -> public DNS -> router -> chakra's
  traefik (:80/:443) -> netbird container. Chakra down = mesh control-plane
  down; existing WireGuard tunnels keep working, new peers/re-join don't.
- **\*.p.marceloborges.dev -> caddy -> TrueNAS apps**: Cloudflare DNS-01
  (CLOUDFLARE_API_TOKEN in `~/server/caddy` compose env), proxies ~10 apps
  via NetBird mesh DNS `truenas.i.marceloborges.dev:30xxx`.
- **konoha <-> mac-mini**: vmhgfs share; mac-mini launchd agent watches
  `clipboard.txt` on it using `~/.cargo/bin/fswatcher` (unmanaged binary)
  and sources `~/.zshrc`.
- **chakra -> TrueNAS NFS**: automount `/mnt/nfs-chakra` (`truenas.home`);
  `hosts/chakra/modules/backups.nix` orders on the automount unit name
  derived from the mountpoint path - renaming the mountpoint breaks the
  backup's ordering.
- **TrueNAS graceful shutdown of chakra/caddy**: `services.qemuGuest.enable`;
  if the guest agent breaks, TrueNAS hard-kills the VMs.

## Untracked state each host depends on

- chakra + caddy: `~/server` = separate repo (`jmarcelomb/server`), docker
  compose stacks, crowdsec credentials (gitignored there).
- mac-mini: opencode config + plugins; hermes/hindsight installs
  (`scripts/hindsight-ui`); `~/.cargo/bin/fswatcher`.
- Git signing: byakugan's key only. CI (GitHub) verifies nothing (commits
  from other hosts are unsigned by design).

## Agent tooling (replaces dsh, removed 2026-10)

opencode2 + hermes agent. No dsh services remain in the flake.

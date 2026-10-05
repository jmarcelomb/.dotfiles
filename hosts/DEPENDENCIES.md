# Host & External Dependency Map

Everything that connects the hosts to each other and to infrastructure
OUTSIDE this flake. If you change any piece mentioned here, check the
arrows. (Sanitized for the public repo: LAN addresses and exact schedule
times intentionally vague - fill in from your own notes/router.)

## Fleet

| Host | What | Notes |
|---|---|---|
| mac-mini | aarch64-darwin, daily driver | keystone: hosts the konoha VM, receives chakra's backups |
| konoha | aarch64-linux sway desktop VM (VMware Fusion on mac-mini) | often off; shares a VMware folder ↔ `/mnt/hgfs` |
| chakra | x86_64-linux server VM on TrueNAS | docker stacks from `~/server` (private repo `jmarcelomb/server`) |
| caddy | x86_64-linux VM (chakra clone) | reverse proxy + netbird client only |
| byakugan | x86_64-linux sway laptop | holds the GPG commit-signing key (`includeIf hostname:byakugan`) |

## Cross-host contracts

- **chakra -> mac-mini (nightly offsite rsync)**: authenticates with a
  dedicated SSH key; mac-mini's authorized_keys pins it with
  `command="..." restrict from="<chakra's LAN IP>"`. **chakra's IP is a
  contract enforced on mac-mini but assigned outside the flake** (router/
  TrueNAS DHCP). Re-IP chakra and the offsite backup dies silently (the
  NFS backup keeps working - half-healthy, easy to miss).
- **caddy -> chakra (nightly state push)**: `hosts/caddy/modules/backups.nix`
  rsyncs caddy/netbird volumes into chakra's `~/server/volumes/caddy-guest/`
  (dedicated SSH key authorized on chakra, IP-pinned) so chakra's own
  backups carry them onward.
- **caddy VM -> chakra netbird server**: the client's management URL
  resolves through public DNS -> router -> chakra's traefik -> netbird
  container. Chakra down = mesh control-plane down; existing WireGuard
  tunnels keep working, new peers/re-join don't.
- **public app domains -> caddy -> TrueNAS apps**: Cloudflare DNS-01
  (token in the private server repo), proxies the app fleet via NetBird
  mesh DNS names.
- **konoha <-> mac-mini**: vmhgfs share; mac-mini launchd agent watches
  a file on it using an unmanaged `~/.cargo/bin/fswatcher` binary and
  sources `~/.zshrc`.
- **chakra -> TrueNAS NFS**: automount of the backup share;
  `hosts/chakra/modules/backups.nix` orders on the automount unit name
  derived from the mountpoint path - renaming the mountpoint breaks the
  backup's ordering.
- **TrueNAS graceful shutdown of the server VMs**: `services.qemuGuest.enable`;
  if the guest agent breaks, TrueNAS hard-kills the VMs.

## Untracked state each host depends on

- chakra + caddy: `~/server` = private repo (`jmarcelomb/server`), docker
  compose stacks, crowdsec credentials (gitignored there).
- mac-mini: opencode config + plugins; hermes/hindsight installs
  (`scripts/hindsight-ui`); `~/.cargo/bin/fswatcher`.
- Git signing: byakugan's key only; commits from other hosts are unsigned.

## Agent tooling (replaces dsh, removed 2026-10)

opencode2 + hermes agent. No dsh services remain in the flake.

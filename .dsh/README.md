# DSH on mac-mini — setup and runbook

Personal AI harness: always-on `dsh web` reachable over NetBird, Memorix
memory stored locally, Context7/GitHub MCPs, `dsh-tui` for terminal coding.
Everything here is versioned in this (public) repo; **secrets never are**.

## Architecture

```
phone/laptop ──NetBird──> socat @ 100.106.113.49:3080   (LaunchAgent dsh-web-netbird)
                              └──> dsh web @ 127.0.0.1:3080   (LaunchAgent dsh-web)
                                       ├── Memorix MCP  (stdio, ~/.memorix/data, sqlite)
                                       ├── Context7 MCP (HTTP, token from ~/.dsh/mcp-env)
                                       └── GitHub MCP   (HTTP, token from ~/.dsh/mcp-env)
dsh-tui (`dshc`) shares all of the above via ~/.dsh/cordis.patch.yml.
```

- **LaunchAgents** (nix: `hosts/mac-mini/dsh-web.nix`): `com.user.dsh-web`,
  `com.user.dsh-web-netbird` (socat), `com.user.dsh-memory-backup` (nightly
  03:30 git snapshot of memory+sessions to `~/.local/share/dsh-backups`).
- **Wrapper**: `scripts/dsh-web` — sources `~/.dsh/mcp-env`, resolves the
  nvm node store (`~/.local/share/nvm` first, `~/.config/nvm` fallback),
  passes `--trusted-host` for `DSH_WEB_HOST` and `NETBIRD_IP`.
- **Config shared by all profiles**: `~/.dsh/cordis.patch.yml` (symlink to
  `.dsh/cordis.patch.yml` here) + `~/.dsh/AGENTS.md` (symlink to
  `.dsh/AGENTS.md`). Installed by dotbot (`install.conf.yaml`).
- **Secrets**: `~/.dsh/mcp-env` (chmod 600) — tokens, `NETBIRD_IP`,
  `DSH_WEB_HOST`. Template: `.dsh/mcp-env.example`. Fish loads it via
  `.config/fish/conf.d/99-mcp-env.fish`.

## Daily operations

| Task | Command |
|---|---|
| Phone/laptop URL | `grep "dsh web:" ~/Library/Logs/dsh-web/out.log \| tail -1` (swap host for `mac-mini.i.marceloborges.dev` or the NetBird IP; one token visit per browser, then a 30-day cookie) |
| Restart the service | `launchctl kickstart -k gui/501/com.user.dsh-web` |
| Service status | `launchctl list \| grep dsh` |
| Terminal coding | `dshc` (= `dsh --profile dsh-tui`) |
| Backup status | `tail ~/Library/Logs/dsh-web/backup.log`; repo at `~/.local/share/dsh-backups` |
| Apply config changes | edit files here → `darwin-rebuild switch --flake ~/.dotfiles#mac-mini` (nix-managed parts) |

## Updating

```fish
npm install -g @deepseek-ai/dsh @deepseek-harness-tui/dsh-tui memorix   # nvm store
dsh plugin --profile web add dsh-better-sidebar@latest                  # plugins
launchctl kickstart -k gui/501/com.user.dsh-web                         # restart
```

Node upgrades under nvm move npm globals: the wrapper self-adjusts PATH,
but reinstall the globals above under the new node.

## Rollbacks

- Plugin trouble: `dsh plugin --profile web remove <pkg>` + kickstart.
- Service trouble: `launchctl unload ~/Library/LaunchAgents/com.user.dsh-web.plist` and run `dsh web` manually.
- Memory restore: copy `memorix/memorix.db` from a snapshot in
  `~/.local/share/dsh-backups` back to `~/.memorix/data/` (service stopped).

## Known notes

- `dsh web` deliberately refuses `--host 0.0.0.0`; remote access is
  NetBird-only (socat binds just the NetBird IP).
- dsh's MCP client sends no workspace roots: memorix runs `--mode lite` and
  every session binds its project via `memorix_session_start` (instructed in
  `AGENTS.md`).
- Optional: front with Caddy (`caddy/dsh.caddyfile`) for HTTPS + password
  login at `dsh.i.marceloborges.dev`.
- Time Machine has no destination configured — the nightly snapshot is
  local-only. Add a TM destination or a git remote for off-site copies.

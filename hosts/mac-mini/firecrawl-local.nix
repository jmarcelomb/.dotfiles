# Firecrawl Local (single Rust binary, v2 API on 127.0.0.1:3002) as a launchd user
# agent, so Hermes' web_extract keeps working after reboot without a free-tier key.
#
# Binary comes from `cargo install firecrawl-local` into ~/.cargo/bin, NOT from
# nixpkgs (not packaged there as of 0.1.0). Building it needs Apple clang + SDKROOT:
#   export SDKROOT=$(xcrun --show-sdk-path)
#   export CC=/usr/bin/clang CXX=/usr/bin/clang++
#   export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=/usr/bin/clang
#   cargo install firecrawl-local
# (nix's `cc` is GCC, which fails the aws-lc-sys link step with `-liconv`.)
#
# Updating is manual and independent of darwin-rebuild: nixpkgs has no
# firecrawl-local attribute and there is no brew formula, so this file pins the
# launchd wrapper, not the version. Use the dotfiles script, which runs the
# clang/SDKROOT exports, the cargo install and the restart in one go:
#   ~/scripts/firecrawl-local-update check    # installed vs crates.io
#   ~/scripts/firecrawl-local-update apply    # build latest, then kickstart
# A cold build takes ~30 min; the service keeps serving the old binary until
# the kickstart, so a failed build changes nothing.
#
# FIRECRAWL_CLOUD=off keeps every fetch local: no search, no blocked-page
# hand-off to Firecrawl Cloud. Search stays on searxng, which Hermes already uses.
{ user, homeDirectory, ... }:

let
  cfg = {
    port = 3002;
    bin = "${homeDirectory}/.cargo/bin/firecrawl-local";
    logDir = "${homeDirectory}/.hermes/logs";
  };
in
{
  launchd.user.agents.firecrawl-local = {
    script = ''
      export FIRECRAWL_CLOUD=off
      exec ${cfg.bin} serve --port ${toString cfg.port}
    '';
    serviceConfig = {
      Label = "io.firecrawl.local";
      RunAtLoad = true;
      KeepAlive = true; # restart on crash; Hermes falls back to the keyless ring only on hard errors
      ProcessType = "Background";
      StandardOutPath = "${cfg.logDir}/firecrawl-local.launchd.out.log";
      StandardErrorPath = "${cfg.logDir}/firecrawl-local.launchd.err.log";
    };
  };
}

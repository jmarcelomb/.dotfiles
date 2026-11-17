# Jellyfin media server, moved off the TrueNAS app (2026-11-17).
#
# The NAS host (i5-4690, GTX 970) cannot transcode 4K HEVC 10-bit / Dolby
# Vision remuxes: Maxwell NVDEC/NVENC is h264-only, so every HEVC transcode
# fell back to software on 4 Haswell cores and stuttered. This machine (M2
# Pro) does it on the media engine: verified with jellyfin-ffmpeg 8.1.3
# decoding 4K HEVC 10-bit via -hwaccel videotoolbox and re-encoding with
# h264_videotoolbox faster than realtime. VideoToolbox requires the NATIVE
# build - running this under Docker/OrbStack would place it in a Linux VM
# with no access to the media engine.
#
# Layout:
#   ~/server/jellyfin  server data (DBs, config, metadata), migrated from the
#                      TrueNAS app's storage-configuration with library paths
#                      rewritten (mblink files + BaseItems.Path prefix swap)
#   ~/server/nas-media NFS mount of the TrueNAS media dataset (export has
#                      mapall so the uid mismatch with the NAS owner does not
#                      matter; rw because Jellyfin writes nfo/subtitles beside
#                      media)
#
# The old NAS app is the rollback path (sudo midclt call app.start
# id=jellyfin) - keep it stopped, do not delete it.
{ pkgs, user, homeDirectory, ... }:

let
  # DHCP lease with router reservation (same situation as hermes-dashboard.nix)
  nasLanIp = "192.168.0.235";
  nfsExport = "/mnt/nas/samba/marcelo/jellyfin";
  dataDir = "${homeDirectory}/server/jellyfin";
  cacheDir = "${dataDir}/transcodes";
  logDir = "${homeDirectory}/Library/Logs/jellyfin";
  mediaMount = "${homeDirectory}/server/nas-media";
in
{
  # macOS enforces NFS file permissions locally against the uid/gid the
  # server reports. Media on the NAS is owned 3001:568 with mode 770 (dirs
  # made by the arr containers are uid 568), so user 501 gets denied at
  # open() even though the server-side mapall would allow it. A local group
  # with the NAS's gid 568 containing the user makes the group bits apply.
  # (users.groups does not work for standalone groups in this nix-darwin -
  # activation only creates groups referenced by users.users - so the group
  # is managed with idempotent dscl calls below.)

  # No fileSystems option in this nix-darwin - the NFS mount goes through
  # /etc/fstab (macOS autofsd mounts nfs entries from fstab). /etc/fstab is
  # NOT managed declaratively because it already carries the Determinate Nix
  # Installer's /nix apfs entry, which must survive untouched; the activation
  # below only appends our line once. NOTE: custom system.activationScripts
  # entries never run in nix-darwin unless a standard target pulls them in,
  # hence extraActivation here.
  system.activationScripts.extraActivation.text = ''
    # Local group mirroring the NAS apps gid (see comment above)
    if ! dscl . -read /Groups/nas-media PrimaryGroupID >/dev/null 2>&1; then
      dscl . -create /Groups/nas-media PrimaryGroupID 568
      dscl . -create /Groups/nas-media RealName 'NAS media (gid 568) for NFS access'
    fi
    if ! dscl . -read /Groups/nas-media GroupMembership 2>/dev/null | grep -qw '${user}'; then
      dscl . -append /Groups/nas-media GroupMembership '${user}'
    fi

    mkdir -p "${dataDir}" "${cacheDir}" "${logDir}" "${mediaMount}"
    chown "${user}:staff" "${dataDir}" "${cacheDir}" "${logDir}"
    # NB: never chown the media mount - once fstab automounts the NFS export
    # there, chown fails (Operation not permitted) and aborts the whole
    # activation switch
    if ! grep -q '${nasLanIp}:${nfsExport}' /etc/fstab; then
      printf '%s:%s %s nfs rw,resvport,locallocks\n' \
        '${nasLanIp}' '${nfsExport}' '${mediaMount}' >> /etc/fstab
    fi
    # mount now if the export is already up (best effort; boot automount
    # covers the normal path)
    automount -cv >/dev/null 2>&1 || true
  '';

  launchd.user.agents.jellyfin = {
    path = with pkgs; [ jellyfin-ffmpeg ];
    serviceConfig = {
      Label = "com.user.jellyfin";
      ProgramArguments = [
        "${pkgs.jellyfin}/bin/jellyfin"
        "--service"
        "--datadir"
        dataDir
        "--cachedir"
        cacheDir
        "--configdir"
        "${dataDir}/config"
        "--logdir"
        logDir
        # NB: do NOT pass --ffmpeg here - the nixpkgs wrapper already adds
        # --ffmpeg (and --webdir); a second one makes the arg parser abort
        # with "Option 'ffmpeg' is defined multiple times"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Adaptive"; # transcoding must not be throttled like Background
      StandardOutPath = "${logDir}/launchd.out";
      StandardErrorPath = "${logDir}/launchd.out";
    };
  };
}

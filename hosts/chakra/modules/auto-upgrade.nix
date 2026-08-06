{ inputs, ... }:
{
  # NOTE: currently disabled in configuration.nix. Kept here so we can
  # enable it later if we want unattended updates.
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    # Fixed: postUpgrade lives directly under system.autoUpgrade (not nested).
    postUpgrade = ''
      cd ${inputs.self.outPath}
      git pull --rebase
      git push
    '';
  };
}

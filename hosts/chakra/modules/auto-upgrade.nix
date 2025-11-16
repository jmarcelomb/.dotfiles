{ inputs, ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
      "--commit-lock-file"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
    system.autoUpgrade.postUpgrade = ''
      cd ${inputs.self.outPath}
      git pull --rebase
      git push
    '';
  };
}

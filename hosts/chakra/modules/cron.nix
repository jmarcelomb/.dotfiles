{ config, lib, pkgs, ... }:
{
  services.cron = {
    enable = true;
    systemCronJobs = [
      # run daily at 20:00 (8:00pm)
      "0 20 * * *   sudo rsync -r --delete ~/server jmmb@192.168.1.124:~/"
    ];
  };
}

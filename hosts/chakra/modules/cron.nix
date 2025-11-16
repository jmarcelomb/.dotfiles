{ config, lib, pkgs, ... }:
{
  services.cron = {
    enable = true;
    systemCronJobs = [
      # run daily at 20:00 (8:00pm)
      "0 20 * * *   sudo rsync -r --delete ~/server jmmb@192.168.1.124:~/"
      # Backup Docker volumes to NAS daily at 2:00 AM
      # to check logs do: journalctl -t docker-backup
      "0 2 * * *   root   rsync -av --delete /home/hinata/server/volumes/ /mnt/nfs-chakra/docker-volumes-backup/ 2>&1 | logger -t docker-backup"
    ];
  };
}

{
  services.restic.backups = {
    local-system-backup = {
      # Automatically create the repository if it doesn't exist
      initialize = true;

      repository = "/data/backups";

      passwordFile = "/root/restic-password";

      paths = [
        "/"
      ];

      exclude = [
        "/data/backups"
        "/data/media/torrents"

        # Standard virtual filesystems that shouldn't be backed up
        "/dev"
        "/proc"
        "/sys"
        "/run"
        "/tmp"
        "/var/tmp"
        "/var/run"
        "/nix/store"
      ];

      # Additional arguments to pass to the `restic backup` command
      extraBackupArgs = [
        "--exclude-caches" # Automatically excludes directories containing CACHEDIR.TAG
      ];

      # Schedule the backup (Systemd Timer configuration)
      timerConfig = {
        OnCalendar = "*-*-* 4:00:00";
        Persistent = true;
      };

      # Automatically clean up old backups to save space
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
    };
  };
}

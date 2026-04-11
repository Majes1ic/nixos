{
  services.restic.backups = {
    local-system-backup = {
      # Automatically create the repository if it doesn't exist
      initialize = true;

      # The local directory where backups will be stored
      repository = "/data/backups";

      # Restic requires a password to encrypt the repository.
      # Create this file manually using `echo "yourpassword" > /root/restic-password`
      passwordFile = "/root/restic-password";

      # What to backup ("/" means the entire filesystem)
      paths = [
        "/"
      ];

      # What to exclude
      exclude = [
        # Exclude the backup destination itself (CRITICAL when backing up "/")
        "/data/backups"

        # The specific paths you mentioned
        # (Adjust these if your typo meant separate folders like "/data" and "/test")
        "/data/media/torrents"

        # Standard virtual filesystems that shouldn't be backed up
        "/dev"
        "/proc"
        "/sys"
        "/run"
        "/tmp"
        "/var/tmp"
        "/var/run"
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

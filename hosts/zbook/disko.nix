# configure:
#
# Swap partition
# EFI partition
# Files partition
#
# zfs

{
  inputs,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.default ];
  disko.devices.disk.main = {
    type = "disk";
    # Find it on the installer with: ls -l /dev/disk/by-id | grep nvme
    device = "/dev/disk/by-id/nvme-SK_hynix_PC801_HFS001TEJ9X101N_SNC4N494810304B58";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}

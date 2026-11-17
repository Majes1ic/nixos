# configure:
#
# Swap partition
# EFI partition
# Files partition
#
# zfs

{
  inputs,
  hostname,
  ...
}:
let
  pseudoRoot = "${hostname}-nixos";
in
{
  imports = [ inputs.disko.nixosModules.default ];
  disko.devices = {
    disk.max-root = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NX0W403726X";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "boot";
            size = "1024M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "umask=0077"
              ];
            };
          };
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "max-zroot";
            };
          };
        };
      };
    };
    zpool.max-zroot = {
      type = "zpool";
      options.ashift = "12";

      rootFsOptions = {
        atime = "off";
        mountpoint = "none";
        xattr = "sa";
        acltype = "posixacl";
        compression = "lz4";
      };

      datasets = {
        ${pseudoRoot}.type = "zfs_fs";

        "${pseudoRoot}/root" = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
      };
    };
  };
}

{
  disko.devices.disk.main = {
    type = "disk";
    # Framework 13 NVMe - use disk ID for stable reference
    # Find with: ls -la /dev/disk/by-id/ | grep nvme
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_XXXXXX";
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
            passwordFile = "/tmp/disk-password";
            settings.allowDiscards = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}

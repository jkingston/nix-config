{
  disko.devices.disk.main = {
    type = "disk";
    # Crucial P3 Plus 500GB NVMe SSD
    device = "/dev/disk/by-id/nvme-CT500P3PSSD8_241147836F99";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}

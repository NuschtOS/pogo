{ eval }:

eval {
  networking.hostName = "storage1";

  disko = {
    disks = [
      # root
      {
        device = "/dev/disk/by-id/ata-SSDSC2KB480G8R_PHYF847601NQ480BGN";
        name = "root1";
        withBoot = true;
        zfsMode = "mirror";
        zpoolName = "root";
      }
      {
        device = "/dev/disk/by-id/ata-SSDSC2KB480G8R_PHYF847601N6480BGN";
        name = "root2";
        withBootPlacebo = true;
        zfsMode = "mirror";
        zpoolName = "root";
      }
      # microvms
      {
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_1TB_S3Z9NB0M203728K";
        name = "ssd-microvm1";
        zfsMode = "mirror";
        zpoolName = "ssd-microvm";
      }
      {
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_1TB_S3Z9NB0M203731L";
        name = "ssd-microvm2";
        zfsMode = "mirror";
        zpoolName = "ssd-microvm";
      }

      # storage
      {
        device = "/dev/disk/by-id/scsi-35000c500a6f5b8c3";
        name = "hdd-storage1";
        zfsMode = "raidz1";
        zpoolName = "hdd-storage";
      }
      {
        device = "/dev/disk/by-id/scsi-35000c500a71f2a63";
        name = "hdd-storage2";
        zfsMode = "raidz1";
        zpoolName = "hdd-storage";
      }
      {
        device = "/dev/disk/by-id/scsi-35000c500a6f62857";
        name = "hdd-storage3";
        zfsMode = "raidz1";
        zpoolName = "hdd-storage";
      }
    ];
    stateVersion = "1.0";
  };
}

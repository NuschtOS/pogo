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

      # media
      {
        device = "/dev/disk/by-id/ata-WDC_WUH721818ALE6L4_3FJA3LLT";
        name = "hdd-media1";
        zfsMode = "mirror";
        zpoolName = "hdd-media";
      }
      {
        device = "/dev/disk/by-id/ata-WDC_WUH721818ALE6L4_3FJA0B5T";
        name = "hdd-media2";
        zfsMode = "mirror";
        zpoolName = "hdd-media";
      }
      {
        device = "/dev/disk/by-id/ata-WDC_WUH721818ALE6L4_3FKJAV6U";
        name = "hdd-media3";
        # https://github.com/nix-community/disko/blob/83c4da299c1d7d300f8c6fd3a72ac46cb0d59aae/example/zfs-with-vdevs.nix#L243-L299
        zfsMode.topology = {
          spare = [ "hdd-media3" ];
          type = "topology";
          vdev = [ {
            mode = "mirror";
            members = [
              "hdd-media1"
              "hdd-media2"
            ];
          } ];
        };
        zpoolName = "hdd-media";
      }
    ];
    stateVersion = "1.0";
  };
}

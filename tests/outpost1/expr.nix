{ eval }:

eval {
  disko = {
    disks = [
      {
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LM480HCHP-00003_S1YJNX0H401022";
        name = "root1";
        bootDir = "/boot1";
        withMirroredBoot = true;
        partitionTableFormat = "msdos";
        zfsMode = "mirror";
        zpoolName = "root";
      }
      {
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LM480HMHQ-00005_S2UJNX0H801406";
        name = "root2";
        bootDir = "/boot2";
        withMirroredBoot = true;
        partitionTableFormat = "msdos";
        zfsMode = "mirror";
        zpoolName = "root";
      }
    ];
    enableConfig = true;
    stateVersion = "1.1";
  };
}

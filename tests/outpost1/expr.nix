{ eval }:

eval {
  # networking.hostName = "outpost1";

  disko = {
    disks = [
      {
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LM480HCHP-00003_S1YJNX0H401022";
        name = "root1";
        withMirroredBoot = true;
        bootDir = "/boot1";
        zfsMode = "mirror";
        zpoolName = "root";
      }
      {
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LM480HMHQ-00005_S2UJNX0H801406";
        name = "root2";
        withMirroredBoot = true;
        bootDir = "/boot2";
        zfsMode = "mirror";
        zpoolName = "root";
      }
    ];
    stateVersion = "1.1";
  };
}

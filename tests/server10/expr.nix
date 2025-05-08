{ eval }:

eval {
  networking.hostName = "server10";

  disko = {
    disks = [ {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_1TB_S3Z9NB0M203733F";
      name = "root";
      partitionTableFormat = "msdos";
      withBoot = true;
    } ];
    stateVersion = "1.0";
  };
}

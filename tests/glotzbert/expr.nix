{ eval }:

eval {
  networking.hostName = "glotzbert";

  disko = {
    disks = [ {
      device = "/dev/disk/by-id/ata-SSD0240S00_20201124BC41037";
      name = "glotzbert";
      withBoot = true;
      withLuks = false;
    } ];
    stateVersion = "1.0";
  };
}

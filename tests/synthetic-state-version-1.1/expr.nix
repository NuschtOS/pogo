{ eval }:

eval {
  networking.hostName = "synthetic";

  disko = {
    disks = [ {
      device = "/dev/disk/by-id/ata-SSD0240S00_20201124BC41037";
      name = "glotzbert";
      withBoot = true;
      withZfs = true;
    } ];
    stateVersion = "1.1";
  };
}

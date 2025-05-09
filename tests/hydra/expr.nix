{ eval }:

eval {
  networking.hostName = "hydra";

  disko = {
    disks = [ {
      device = "/dev/disk/by-id/ata-CT2000MX500SSD1_2039E4B20F95";
      name = ""; # legacy reasons, properly name on next format
      withBoot = true;
    } ];
    stateVersion = "1.1";
  };
}

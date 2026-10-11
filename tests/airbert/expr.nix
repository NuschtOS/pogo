{ eval }:

eval {
  networking.hostName = "airbert";

  disko = {
    disks = [ {
      bootDevice = "/dev/disk/by-uuid/C987-1CFF";
      device = "/dev/disk/by-id/nvme-APPLE_SSD_AP0256Q_0ba018e3e389402b";
      name = "root";
      withBoot = true;
      withLuks = false;
    } ];
    enableConfig = true;
    stateVersion = "1.2";
  };
}

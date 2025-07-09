{ config, lib, ... }:

let
  cfg = config.disko.disks;
in
{
  options.disko = {
    disks = lib.mkOption {
      description = "Disks to format.";
      type = lib.types.listOf (lib.types.submodule ({ config, ... }: {
        options = {
          device = lib.mkOption {
            type = lib.types.str;
            default = null;
            example = "/dev/sda";
            description = "Path of the disk.";
          };

          name = lib.mkOption {
            type = lib.types.str;
            example = "ssd0";
            description = "Name of the disk.";
          };

          partitionTableFormat = lib.mkOption {
            type = lib.types.enum [ "gpt" "msdos" ];
            default = "gpt";
            description = "Which partitions table format to use.";
          };

          withBoot = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to include a boot partition.";
          };

          bootDir = lib.mkOption {
            type = lib.types.str;
            default = "/boot";
            description = "The path to the directory where the boot directory is mounted. This can be used for `boot.loader.grub.mirroredBoots`.";
          };

          withBootPlacebo = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to include a boot partition that is not mounted.";
          };

          withMirroredBoot = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to write this disk with the configured `bootDir` into `boot.loader.grub.mirroredBoots`.";
          };

          # TODO: bring function back
          withCeph = lib.mkOption {
            type = lib.types.bool;
            default = false;
            internal = true; # TODO: drop when ready
            description = "Whether to include a ceph partition.";
          };

          withLuks = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to encrypt the partitions.";
          };

          withZfs = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to include a zfs partitions.";
          };

          zfsMode = lib.mkOption {
            type = with lib.types; nullOr (types.oneOf [ str deferredModule ]);
            default = null;
            description = ''
              The mode of this zpool. Valid values include mirror and raidz1.
              Full list is available at <https://search.nüschtos.de/?option_scope=3&option=disko.devices.zpool.%3Cname%3E.mode&query=disko*mode>.
            '';
          };

          zpoolName = lib.mkOption {
            type = lib.types.str;
            default = config.name;
            description = "The name of the zpool. When doing a zfs mirror this must match the other device.";
          };
        };
      }));
      default = [ ];
    };

    stateVersion = lib.mkOption {
      type = lib.types.enum [ "1.0" "1.1" ];
      description = ''
        This option makes sure that the fileSystem output for a system never changes.
        This option can be manually bumped but the it is the end users duty to make sure that everything has been manually changed accordingly!
      '';
    };
  };

  config = {
    assertions = lib.mkIf (cfg != [ ]) (lib.head (map
      (disk: [
        {
          assertion = disk.withZfs;
          message = "Must enable ZFS! (Currently nothing else is supported)";
        }
        {
          assertion = !disk.withCeph;
          message = "Ceph has currently no function and must stay disabled!";
        }
        # TODO: bring back
        # {
        #   assertion = disk.withCeph || disk.withZfs;
        #   message = "Must enable Ceph or ZFS!";
        # }
        # {
        #   assertion = disk.withCeph -> disk.withLuks;
        #   message = "Ceph requires Luks!";
        # }
      ])
      cfg));

    boot.loader.grub.mirroredBoots = map (disk: {
      devices = [ disk.device ];
      path = disk.bootDir;
    }) (lib.filter (disk: disk.withMirroredBoot) cfg);

    disko = {
      devices = lib.mkIf (cfg != [ ]) (lib.foldl' (a: b: lib.recursiveUpdate a b) { } (map
        (disk:
          let
            diskName = if disk.name == "" then "" else "-"+disk.name;
            luksName = "${config.networking.hostName}${diskName}";
            withBoot = disk.withBoot || disk.withBootPlacebo || disk.withMirroredBoot;
            version = config.disko.stateVersion;
            zfsName = config.networking.hostName + (if disk.zpoolName == "" then "" else "-"+disk.zpoolName);
            zfs = {
              size = "100%FREE";
              content = {
                pool = zfsName;
                type = "zfs";
              };
            };
          in
          {
            disk.${disk.device} = {
              inherit (disk) device;
              type = "disk";
              content = {
                type = "table";
                format = disk.partitionTableFormat;
                partitions = lib.optional withBoot {
                  name = "ESP";
                  start = "1MiB";
                  end = "512MiB";
                  bootable = true;
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = lib.mkIf (disk.withBoot || disk.withMirroredBoot) disk.bootDir; # TODO: remove withBootPlacebo and do this properly
                  };
                } ++ [
                  {
                    name = "root";
                    start = if withBoot then "512MiB" else "1MiB";
                    end = "100%";
                    part-type = "primary";
                    content = lib.optionalAttrs disk.withLuks {
                      type = "luks";
                      name = luksName;
                      askPassword = true;
                      inherit (zfs) content;
                    } // lib.optionalAttrs (!disk.withLuks) zfs.content;
                  }
                ];
              };
            };
          } // (lib.optionalAttrs disk.withZfs {
            zpool.${zfsName} = {
              type = "zpool";
              mode = lib.mkIf (disk.zfsMode != null) disk.zfsMode;
              # -O
              rootFsOptions = {
                acltype = "posixacl";
                compression = "zstd";
                dnodesize = "auto";
                normalization = "formD";
                mountpoint = "none";
                xattr = "sa";
              };
              # -o
              options = {
                ashift = "12";
                autotrim = "on";
              };
              datasets =
                let
                  dataset = mountpoint: {
                    inherit mountpoint;
                    options = {
                      canmount = "on";
                      inherit mountpoint;
                    };
                    type = "zfs_fs";
                  };

                  datasetNoMount = {
                    mountpoint = null;
                    options = {
                      canmount = "off";
                      mountpoint = "none";
                    };
                    type = "zfs_fs";
                  };
                in
                {
                  "data" = lib.recursiveUpdate datasetNoMount {
                    options."com.sun:auto-snapshot" = "true";
                  };
                  # zfs uses copy on write and requires some free space to delete files when the disk is completely filled
                  "reserved" = lib.recursiveUpdate (dataset "reserved") {
                    mountpoint = null;
                    options = {
                      canmount = "off";
                      mountpoint = "none";
                      reservation = "5GiB";
                    };
                    type = "zfs_fs";
                  };
                } // lib.optionalAttrs withBoot ({
                  "root" = lib.recursiveUpdate (dataset "/") {
                    options."com.sun:auto-snapshot" = "true";
                  };
                  "data/etc" = dataset "/etc";
                } // (if lib.versionAtLeast version "1.1" then {
                  "data/var" = dataset "/var";
                  # used by services.postgresqlBackup and later by restic
                  "data/var/backup" = dataset "/var/backup";
                  "data/var/lib" = dataset "/var/lib";
                  "data/var/log" = dataset "/var/log";
                } else {
                  # used by services.postgresqlBackup and later by restic
                  "data/backup" = dataset "/var/backup";
                  "data/lib" = dataset "/var/lib";
                }) // {
                  "home" = dataset "/home" // {
                    options."com.sun:auto-snapshot" = "true";
                  };
                  "nix" = lib.recursiveUpdate (dataset "/nix") {
                    options.atime = "off";
                  };
                  "nix/store" = dataset "/nix/store";
                  "nix/var" = dataset "/nix/var";
                });
            };
          }))
        cfg));
    };
  };
}

{ lib, config, ... }:
let
  cfg = config.myFeatures.core.system.disko;

  # Filter out the main disk from the list of additional disks
  extraDisks = lib.filter (d: d != cfg.mainDisk) cfg.disks;

  # ESP partition only on the main disk
  mkMainDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "2G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted-main";
            # settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
              ]
              ++ (map (d: "/dev/mapper/crypted-${lib.strings.sanitizeDerivationName d}") extraDisks);
              subvolumes = {
                "/root" = {
                  mountpoint = "/mnt-root";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };

  # Extra disks only have a LUKS partition
  mkExtraDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted-${lib.strings.sanitizeDerivationName device}";
            # settings.allowDiscards = true;
          };
        };
      };
    };
  };

in
{
  options.myFeatures.core.system.disko = {
    enable = lib.mkEnableOption "Universal Btrfs Shared Pool Disko";
    mainDisk = lib.mkOption {
      type = lib.types.str;
      default = "/dev/nvme0n1";
      description = "The primary disk for ESP and the root subvolume.";
    };
    disks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/dev/nvme0n1" ];
      description = "List of all disks to include in the Btrfs pool.";
    };
  };

  config = lib.mkIf cfg.enable {
    disko.devices = {
      disk = (lib.genAttrs [ cfg.mainDisk ] mkMainDisk) // (lib.genAttrs extraDisks mkExtraDisk);

      nodev."/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=4G"
          "mode=755"
        ];
      };
    };
  };
}

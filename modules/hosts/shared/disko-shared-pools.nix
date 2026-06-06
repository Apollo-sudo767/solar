{ lib, config, ... }:
let
  cfg = config.myFeatures.core.system.disko;

  # Helper to identify disk type from string
  isNVMe = dev: lib.strings.hasInfix "nvme" dev;
  isSSD = dev: lib.strings.hasInfix "sd" dev && !(isHDD dev); # Simple heuristic
  isHDD = dev: false; # User would need to flag these or we use a list

  # Better approach: User provides categorized lists, or we use a single list with a helper
  # Let's stick to the user providing the categories for maximum control

  inherit (cfg) speedDisks;
  inherit (cfg) bulkDisks;

  # The very first disk in speedDisks is our "Primary" (holds ESP)
  mainDisk = lib.head speedDisks;
  otherSpeedDisks = lib.filter (d: d != mainDisk) speedDisks;

  # ESP and Main Speed Pool
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
            name = "crypted-speed-main";
            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "speed"
              ]
              ++ (map (d: "/dev/mapper/crypted-speed-${lib.strings.sanitizeDerivationName d}") otherSpeedDisks);
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

  # Other disks in the speed pool
  mkOtherSpeedDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted-speed-${lib.strings.sanitizeDerivationName device}";
          };
        };
      };
    };
  };

  # Bulk Disks Pool (HDDs)
  mkBulkDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypted-bulk-${lib.strings.sanitizeDerivationName device}";
            # Only the first bulk disk initializes the Btrfs filesystem
            content =
              if device == (lib.head bulkDisks) then
                {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-L"
                    "bulk"
                  ]
                  ++ (map (d: "/dev/mapper/crypted-bulk-${lib.strings.sanitizeDerivationName d}") (
                    lib.drop 1 bulkDisks
                  ));
                  subvolumes = {
                    "/persist/bulk" = {
                      mountpoint = "/persist/bulk";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                }
              else
                null;
          };
        };
      };
    };
  };

in
{
  options.myFeatures.core.system.disko = {
    enable = lib.mkEnableOption "Universal Hardware-Aware Disko";
    speedDisks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/dev/nvme0n1" ];
      description = "List of fast disks (NVMe/SSD) for the primary speed pool.";
    };
    bulkDisks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of slow disks (HDD) for the bulk storage pool.";
    };
  };

  config =
    lib.mkIf
      (config.myFeatures.core.system.core-branch.enable && config.myFeatures.core.system.disko.enable)
      {
        disko.devices = {
          disk =
            (lib.genAttrs [ mainDisk ] mkMainDisk)
            // (lib.genAttrs otherSpeedDisks mkOtherSpeedDisk)
            // (lib.genAttrs bulkDisks mkBulkDisk);

          nodev."/" = {
            fsType = "tmpfs";
            mountOptions = [
              "size=4G"
              "mode=755"
            ];
          };
        };

        # Ensure mounts are available for Preservation
        fileSystems."/persist".neededForBoot = true;
        fileSystems."/persist/bulk" = lib.mkIf (bulkDisks != [ ]) {
          neededForBoot = true;
        };
      };
}

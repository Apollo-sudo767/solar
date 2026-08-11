{
  lib,
  config,
  isDarwin,
  isTotal,
  ...
}:
let
  cfg = config.myFeatures.core.system.disko;
  usePersistence = config.myFeatures.core.system.core-branch.usePersistence or false;

  # Helper to identify disk type from string
  isNVMe = dev: lib.strings.hasInfix "nvme" dev;
  isSSD = dev: lib.strings.hasInfix "sd" dev && !(isHDD dev);
  isHDD = dev: (lib.strings.hasInfix "sda" dev); # /dev/sda is the HDD on mars

  inherit (cfg) speedDisks bulkDisks enableLuks;

  # The very first disk in speedDisks is our "Primary" (holds ESP)
  mainDisk = lib.head speedDisks;
  otherSpeedDisks = lib.filter (d: d != mainDisk) speedDisks;

  # Subvolume definitions based on persistence setting
  rootMountPoint = if usePersistence then "/mnt-root" else "/";

  btrfsContent = {
    type = "btrfs";
    extraArgs = [
      "-f"
      "-L"
      "speed"
    ]
    ++ (
      if enableLuks then
        (map (d: "/dev/mapper/crypted-speed-${lib.strings.sanitizeDerivationName d}") otherSpeedDisks)
      else
        otherSpeedDisks
    );
    subvolumes = {
      "/root" = {
        mountpoint = rootMountPoint;
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

  mainPartitionContent =
    if enableLuks then
      {
        type = "luks";
        name = "crypted-speed-main";
        extraOpenArgs = [ "--allow-discards" ];
        settings.allowDiscards = true;
        settings.crypttabExtraOpts = [ "tpm2-device=auto" ];
        content = btrfsContent;
      }
    else
      btrfsContent;

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
        root = {
          size = "100%";
          content = mainPartitionContent;
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
        root = {
          size = "100%";
          content =
            if enableLuks then
              {
                type = "luks";
                name = "crypted-speed-${lib.strings.sanitizeDerivationName device}";
                settings.allowDiscards = true;
                settings.crypttabExtraOpts = [ "tpm2-device=auto" ];
              }
            else
              null;
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
        bulk = {
          size = "100%";
          content =
            if enableLuks then
              {
                type = "luks";
                name = "crypted-bulk-${lib.strings.sanitizeDerivationName device}";
                settings.allowDiscards = !isHDD device;
                settings.crypttabExtraOpts = [ "tpm2-device=auto" ];
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
              }
            else if device == (lib.head bulkDisks) then
              {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L"
                  "bulk"
                ]
                ++ (lib.drop 1 bulkDisks);
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

in
{
  options.myFeatures.core.system.disko = {
    enable = lib.mkEnableOption "Universal Hardware-Aware Disko";
    enableLuks = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable LUKS encryption on disko partitions.";
    };
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
      (
        lib.mkMerge [
          (lib.optionalAttrs (!isDarwin) {
            disko.devices = {
              disk =
                (lib.genAttrs [ mainDisk ] mkMainDisk)
                // (lib.genAttrs otherSpeedDisks mkOtherSpeedDisk)
                // (lib.genAttrs bulkDisks mkBulkDisk);

              nodev = lib.mkIf usePersistence {
                "/" = {
                  fsType = "tmpfs";
                  mountOptions = [
                    "size=4G"
                    "mode=755"
                  ];
                };
              };
            };

            # Ensure mounts are available for Preservation
            fileSystems."/persist".neededForBoot = lib.mkIf usePersistence true;
            fileSystems."/persist/bulk" = lib.mkIf (bulkDisks != [ ] && usePersistence) {
              neededForBoot = true;
            };
          })
        ]
      );
}

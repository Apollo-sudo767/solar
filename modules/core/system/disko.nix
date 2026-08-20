# modules/core/system/disko.nix
#
# Universal Hardware-Aware Disko Module
#
# Provides a declarative, unified storage foundation across all Linux hosts in Solar:
# - Supports single-disk (NVMe/SSD) and multi-disk (Speed + Bulk) topologies.
# - Formats storage with Btrfs (zstd compression, noatime) and automatic subvolume layouts.
# - Automatically adapts between standard root and wipe-on-boot tmpfs persistence modes.
# - Provides optional full-disk LUKS2 encryption with TPM2 auto-unlock hooks.
# - Fully hardware-agnostic: supports persistent device paths (/dev/disk/by-id/...).
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

  inherit (cfg) speedDisks bulkDisks enableLuks;

  # The very first disk in speedDisks is our "Primary" (holds ESP)
  mainDisk = lib.head speedDisks;
  otherSpeedDisks = lib.filter (d: d != mainDisk) speedDisks;

  btrfsSubvolumesContent = {
    type = "btrfs";
    extraArgs = [
      "-f"
      "-K"
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

  btrfsFilesystemContent = {
    type = "filesystem";
    format = "btrfs";
    mountpoint = "/";
    mountOptions = [
      "compress=zstd"
      "noatime"
    ];
    extraArgs = [
      "-f"
      "-K"
      "-L"
      "speed"
    ]
    ++ (
      if enableLuks then
        (map (d: "/dev/mapper/crypted-speed-${lib.strings.sanitizeDerivationName d}") otherSpeedDisks)
      else
        otherSpeedDisks
    );
  };

  btrfsContent = if usePersistence then btrfsSubvolumesContent else btrfsFilesystemContent;

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
        "${if enableLuks then "luks" else "root"}" = {
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
        "${if enableLuks then "luks" else "root"}" = {
          size = "100%";
          content =
            if enableLuks then
              {
                type = "luks";
                name = "crypted-speed-${lib.strings.sanitizeDerivationName device}";
                extraOpenArgs = [ "--allow-discards" ];
                settings.allowDiscards = true;
                settings.crypttabExtraOpts = [ "tpm2-device=auto" ];
              }
            else
              null;
        };
      };
    };
  };

  # Bulk Disks Pool (HDDs / Storage SSDs)
  mkBulkDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        "${if enableLuks then "luks" else "bulk"}" = {
          size = "100%";
          content =
            if enableLuks then
              {
                type = "luks";
                name = "crypted-bulk-${lib.strings.sanitizeDerivationName device}";
                extraOpenArgs = [ "--allow-discards" ];
                settings.allowDiscards = true;
                settings.crypttabExtraOpts = [ "tpm2-device=auto" ];
                content =
                  if device == (lib.head bulkDisks) then
                    {
                      type = "btrfs";
                      extraArgs = [
                        "-f"
                        "-K"
                        "-L"
                        "bulk"
                      ]
                      ++ (
                        if enableLuks then
                          (map (d: "/dev/mapper/crypted-bulk-${lib.strings.sanitizeDerivationName d}") (lib.drop 1 bulkDisks))
                        else
                          (lib.drop 1 bulkDisks)
                      );
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
                type = "filesystem";
                format = "btrfs";
                mountpoint = "/persist/bulk";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                extraArgs = [
                  "-f"
                  "-K"
                  "-L"
                  "bulk"
                ]
                ++ (lib.drop 1 bulkDisks);
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
            fileSystems = lib.mkIf usePersistence {
              "/persist".neededForBoot = true;
              "/persist/bulk" = lib.mkIf (bulkDisks != [ ]) {
                neededForBoot = true;
              };
            };
          })
        ]
      );
}

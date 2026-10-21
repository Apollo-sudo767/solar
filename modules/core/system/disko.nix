# modules/core/system/disko.nix
# ============================================================================
# Universal Hardware-Aware Disko Storage Module
# ============================================================================
# Provides a declarative, unified storage foundation across Linux hosts in Solar:
#
# Supported Storage Topologies & Modes:
# 1. Single-Disk vs. Multi-Disk Speed Pool (`speedDisks`):
#    - The first drive in `speedDisks` (`mainDisk`) receives a 2GB UEFI System
#      Partition (`/boot`) and the primary Btrfs root partition.
#    - Any additional drives in `speedDisks` (`otherSpeedDisks`) are formatted
#      and spanned into the `speed` Btrfs multi-device pool via `mkfs.btrfs` extraArgs.
# 2. Optional Bulk Storage Pool (`bulkDisks`):
#    - Secondary SATA SSDs or HDDs listed in `bulkDisks` are combined into a
#      separate Btrfs pool labeled `bulk` and mounted at `/persist/bulk`.
# 3. Full-Disk Encryption (`enableLuks = true`):
#    - Wraps every speed and bulk partition in a LUKS2 container with SSD TRIM
#      (`--allow-discards`) and systemd TPM2 auto-unlock (`tpm2-device=auto`).
# 4. Ephemeral Root / Wipe-on-Boot Preservation (`core-branch.usePersistence`):
#    - When `usePersistence = true`: `/` is mounted as a 4GB RAM-backed `tmpfs`
#      that wipes clean on every reboot, while Btrfs subvolumes `/root` (`/mnt-root`),
#      `/nix`, and `/persist` hold persistent state on disk.
#    - When `usePersistence = false`: the `speed` Btrfs filesystem mounts directly
#      at `/` as a traditional persistent root.
# 5. Custom ZFS Mirror / RAIDZ Layouts:
#    - Hosts requiring custom ZFS pools (such as `sol` NAS with a `tank` ZFS mirror)
#      set `myFeatures.core.system.disko.enable = false;` and declare `disko.devices`
#      directly in their host `default.nix`.
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

  # The first disk in `speedDisks` holds the 2GB EFI System Partition (ESP)
  # and acts as the primary Btrfs seed device for the `speed` pool.
  mainDisk = lib.head speedDisks;
  otherSpeedDisks = lib.filter (d: d != mainDisk) speedDisks;

  # Mode A: Ephemeral Root (`usePersistence = true`)
  # Splits the `speed` Btrfs pool into `/root`, `/nix`, and `/persist` subvolumes
  # while `/` itself is mounted as an in-memory `tmpfs`.
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

  # Mode B: Traditional Persistent Root (`usePersistence = false`)
  # Mounts the entire `speed` Btrfs filesystem directly at `/`.
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

  # Optionally wrap the primary Btrfs pool inside a LUKS2 container with TPM2 auto-unlock
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

  # Primary Speed Disk: 2GB VFAT EFI System Partition (`/boot`) + Root/LUKS partition
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

  # Additional Speed Disks: Joined into `mainDisk`'s Btrfs `speed` pool via `extraArgs`
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

  # Bulk Storage Disks (HDDs / Secondary SSDs): Combined into `/persist/bulk`
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
      description = "Enable LUKS2 full-disk encryption on Disko partitions.";
    };
    speedDisks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/dev/nvme0n1" ];
      description = "List of fast disks (NVMe/SSD) for the primary speed pool.";
    };
    bulkDisks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of secondary/bulk disks (HDD/SATA) for the `/persist/bulk` storage pool.";
    };
  };

  config =
    lib.mkIf
      (
        config.myFeatures.core.system.core-branch.enable
        && config.myFeatures.core.system.disko.enable
        && isTotal
      )
      (
        lib.mkMerge [
          (lib.optionalAttrs (!isDarwin) {
            disko.devices = {
              disk =
                (lib.genAttrs [ mainDisk ] mkMainDisk)
                // (lib.genAttrs otherSpeedDisks mkOtherSpeedDisk)
                // (lib.genAttrs bulkDisks mkBulkDisk);

              # Ephemeral RAM-backed root filesystem when `usePersistence = true`
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

            # Mark `/persist` and `/persist/bulk` as required in early boot so
            # `preservation` bind-mounts and services can access persistent files.
            fileSystems = {
              "/persist" = lib.mkIf usePersistence {
                neededForBoot = true;
              };
              "/persist/bulk" = lib.mkIf (bulkDisks != [ ]) {
                neededForBoot = lib.mkDefault true;
              };
            };
          })
        ]
      );
}

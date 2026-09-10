{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = true;
  };

  module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      # Sol: Central Network Attached Storage (NAS) & ZFS Storage Hub
      myFeatures = {
        # 🌲 Dendritic Suites
        suites.server.enable = true;

        # 🎛️ Host & Storage Specifics
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = true;
            };
            # Custom Disko declaration with ZFS mirror pool below
            disko.enable = false;
            users = {
              usernames = [ "apollo" ];
              agenixPassword = true;
            };
          };
          boot = {
            enable = true;
            loader = "limine";
            kernel = "latest";
            secureBoot.enable = false;
          };
          security = {
            security.useAppArmor = true;
            security.useOOMD = true;
            agenix = {
              enable = true;
              usePrivateSecrets = true;
            };
          };
        };

        hardware.cpu-gpu.intel.enable = true;
      };

      # --- ZFS Kernel & Host Identity ---
      boot.supportedFilesystems = [ "zfs" ];
      networking.hostId = "8425e349";

      # --- Declarative Drive Layout via Disko (NVMe Boot + 3.5" HDD ZFS Mirror Pool) ---
      disko.devices = {
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = [
            "size=4G"
            "mode=755"
          ];
        };
        disk = {
          nvme = {
            type = "disk";
            device = "/dev/nvme0n1";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "1G";
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
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
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
          hdd1 = {
            type = "disk";
            device = "/dev/sda";
            content = {
              type = "gpt";
              partitions = {
                zfs = {
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = "tank";
                  };
                };
              };
            };
          };
          hdd2 = {
            type = "disk";
            device = "/dev/sdb";
            content = {
              type = "gpt";
              partitions = {
                zfs = {
                  size = "100%";
                  content = {
                    type = "zfs";
                    pool = "tank";
                  };
                };
              };
            };
          };
        };
        zpool = {
          tank = {
            type = "zpool";
            mode = "mirror";
            rootFsOptions = {
              compression = "lz4";
              "acltype" = "posixacl";
              "xattr" = "sa";
              "atime" = "off";
            };
            datasets = {
              k3s-volumes = {
                type = "zfs_fs";
                mountpoint = "/tank/k3s-volumes";
              };
              storage = {
                type = "zfs_fs";
                mountpoint = "/tank/storage";
              };
              media = {
                type = "zfs_fs";
                mountpoint = "/tank/media";
              };
            };
          };
        };
      };

      # --- Automated ZFS Maintenance & Snapshot Retention ---
      services.zfs.autoScrub = {
        enable = true;
        interval = "weekly";
        pools = [ "tank" ];
      };

      services.zfs.snapshot.enable = true;

      # SMART disk diagnostics
      services.smartd = {
        enable = true;
        autodetect = true;
      };

      # Essential storage utilities
      environment.systemPackages = with pkgs; [
        zfs
        btrfs-progs
        smartmontools
        hdparm
        iotop
        rsync
        rclone
        cifs-utils
        nfs-utils
      ];

      # --- NFS Storage Export (K3s Dynamic Persistent Volumes & Fleet Shares) ---
      services.nfs.server = {
        enable = true;
        exports = ''
          /tank/k3s-volumes 192.168.0.0/16(rw,async,no_subtree_check,no_root_squash) 10.0.0.0/8(rw,async,no_subtree_check,no_root_squash)
          /tank/storage     192.168.0.0/16(rw,sync,no_subtree_check,no_root_squash) 10.0.0.0/8(rw,sync,no_subtree_check,no_root_squash)
          /tank/media       192.168.0.0/16(rw,sync,no_subtree_check,no_root_squash) 10.0.0.0/8(rw,sync,no_subtree_check,no_root_squash)
        '';
      };

      # Samba / SMB File Sharing
      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "Sol Central NAS";
            "netbios name" = "sol";
            "security" = "user";
            "server min protocol" = "SMB3";
            "client min protocol" = "SMB3";
            "hosts allow" = "192.168. 10. 127.0.0.1 localhost 100.";
            "hosts deny" = "0.0.0.0/0";
            "guest account" = "nobody";
            "map to guest" = "never";
          };
          storage = {
            "path" = "/tank/storage";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
          };
          media = {
            "path" = "/tank/media";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
          };
        };
      };

      # Avahi / mDNS
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          userServices = true;
        };
      };

      # Network Security & Firewall (NFS 111 & 2049)
      networking.firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [
          22
          111
          2049
        ];
        allowedUDPPorts = [
          111
          2049
        ];
      };

      services.fail2ban.enable = true;
      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault true;
      };

      # Preservation of NAS State across Wipe-on-Boot
      fileSystems."/persist".neededForBoot = true;

      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" = {
        directories = [
          "/var/lib/samba"
          "/var/lib/nfs"
          "/var/lib/zfs"
        ];
      };

      systemd.tmpfiles.rules = [
        "d /tank/k3s-volumes 0777 root root - -"
        "d /tank/storage 0775 ${config.myFeatures.core.system.users.mainUser} users - -"
        "d /tank/media 0775 ${config.myFeatures.core.system.users.mainUser} users - -"
      ];
    };
}

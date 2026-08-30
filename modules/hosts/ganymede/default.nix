{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = false;
    useSecrets = false;
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

      # Ganymede: Dedicated Network Attached Storage (NAS)
      myFeatures = {
        # 🌲 Dendritic Suites
        suites.server.enable = true;

        # 🎛️ Host & Storage Specifics
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = false;
            };
            disko = {
              enable = true;
              enableLuks = true;
              speedDisks = [ "/dev/nvme0n1" ];
              bulkDisks = [
                "/dev/sda"
                "/dev/sdb"
              ];
            };
            users = {
              usernames = [ "apollo" ];
              agenixPassword = false;
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
            agenix.enable = false;
          };
        };

        hardware.cpu-gpu.intel.enable = true;
      };

      # --- Btrfs Storage Maintenance & SMART Monitoring ---
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [
          "/"
          "/persist/bulk"
        ];
      };

      services.smartd = {
        enable = true;
        autodetect = true;
      };

      # NAS & disk management packages
      environment.systemPackages = with pkgs; [
        btrfs-progs
        smartmontools
        hdparm
        iotop
        rsync
        rclone
        cifs-utils
        nfs-utils
      ];

      # Samba / SMB File Sharing
      services.samba = {
        enable = true;
        openFirewall = true;
        settings = {
          global = {
            "workgroup" = "WORKGROUP";
            "server string" = "Ganymede NAS";
            "netbios name" = "ganymede";
            "security" = "user";
            "server min protocol" = "SMB3";
            "client min protocol" = "SMB3";
            "hosts allow" = "192.168. 10. 127.0.0.1 localhost 100.";
            "hosts deny" = "0.0.0.0/0";
            "guest account" = "nobody";
            "map to guest" = "never";
          };
          storage = {
            "path" = "/persist/bulk/storage";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0644";
            "directory mask" = "0755";
          };
        };
      };

      # NFS Server
      services.nfs.server = {
        enable = true;
        exports = ''
          /persist/bulk/storage 192.168.0.0/16(rw,sync,no_subtree_check,no_root_squash) 10.0.0.0/8(rw,sync,no_subtree_check,no_root_squash)
        '';
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

      # Network Security & Hardening
      networking.firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [
          22
          2049
        ];
        allowedUDPPorts = [
          2049
        ];
      };

      services.fail2ban.enable = true;
      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault true;
      };

      systemd.tmpfiles.rules = [
        "d /persist/bulk/storage 0775 ${config.myFeatures.core.system.users.mainUser} users - -"
      ];
    };
}

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

      # Callisto: General Storage & Backup Host
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
              bulkDisks = [ "/dev/sda" ];
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

      # Storage, backup & recovery tools
      environment.systemPackages = with pkgs; [
        btrfs-progs
        smartmontools
        rsync
        rclone
        restic
        borgbackup
        iotop
        ncdu
      ];

      # Syncthing for encrypted/continuous peer folder synchronization
      services.syncthing = {
        enable = true;
        user = config.myFeatures.core.system.users.mainUser;
        dataDir = "/persist/bulk/syncthing";
        configDir = "/persist/bulk/syncthing/.config/syncthing";
        openDefaultPorts = true;
        guiAddress = "127.0.0.1:8384";
      };

      # Network Security & Hardening
      networking.firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [ 22 ];
      };

      services.fail2ban.enable = true;
      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault true;
      };

      systemd.tmpfiles.rules = [
        "d /persist/bulk/syncthing 0770 ${config.myFeatures.core.system.users.mainUser} users - -"
      ];
    };
}

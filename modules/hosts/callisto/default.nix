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
        core = {
          system.core-branch = {
            enable = true;
            usePersistence = false;
          };
          system.disko = {
            enable = true;
            enableLuks = true;
            speedDisks = [ "/dev/nvme0n1" ]; # High-speed primary pool (Btrfs)
            bulkDisks = [
              "/dev/sda"
            ]; # Bulk Storage pool (Btrfs)
          };
          system.users = {
            usernames = [ "apollo" ];
            agenixPassword = false;
          };
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            loader = "limine";
            kernel = "latest";
            secureBoot.enable = false;
          };
          security.security = {
            enable = true;
            useAppArmor = true;
            useOOMD = true;
          };
          security.ssh.enable = true;
          security.agenix.enable = false;
          nix.lix.enable = true;
        };

        hardware = {
          cpu-gpu.intel.enable = true;
        };

        programs = {
          terminal = {
            ghostty.enable = true;
            fastfetch.enable = true;
            helix.enable = true;
            nh.enable = true;
            direnv.enable = true;
            nix-ld.enable = true;
          };
          utilities = {
            filemanager.enable = true;
          };
        };

        services = {
          hardware.udisks2.enable = true;
          networking = {
            enable = true;
            tailscale.enable = true;
            syncthing.enable = false;
          };
        };
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

      # General storage, backup & recovery tools
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

      # --- Storage & Backup Services ---
      # Syncthing for encrypted/continuous peer folder synchronization
      services.syncthing = {
        enable = true;
        user = config.myFeatures.core.system.users.mainUser;
        dataDir = "/persist/bulk/syncthing";
        configDir = "/persist/bulk/syncthing/.config/syncthing";
        openDefaultPorts = true;
        guiAddress = "127.0.0.1:8384";
      };

      # --- Network Security & Hardening ---
      networking.firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [ 22 ];
      };

      services.fail2ban.enable = true;
      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault true;
      };

      # Automatically provision Syncthing data directory
      systemd.tmpfiles.rules = [
        "d /persist/bulk/syncthing 0770 ${config.myFeatures.core.system.users.mainUser} users - -"
      ];
    };
}

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

      # Jupiter: Intel Mac Mini
      myFeatures = {
        core = {
          system.core-branch = {
            enable = true;
            usePersistence = false;
          };
          system.disko = {
            enable = true;
            enableLuks = true;
            speedDisks = [ "/dev/sda" ]; # Internal disk for Intel Mac Mini
          };
          system.users = {
            usernames = [ "apollo" ];
            agenixPassword = false;
          };
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            loader = "systemd"; # Standard EFI systemd-boot for Apple EFI
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
          system.graphics.enable = true;
          peripherals.bluetooth.enable = true;
          peripherals.wifi = {
            enable = true;
            persistence = true;
          };
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
          multimedia.audio.enable = true;
          hardware.udisks2.enable = true;
          networking = {
            enable = true;
            tailscale.enable = true;
          };
        };
      };

      # System Security & Hardening
      services.fail2ban.enable = true;
      networking.firewall.enable = lib.mkDefault true;
      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault true;
      };
    };
}

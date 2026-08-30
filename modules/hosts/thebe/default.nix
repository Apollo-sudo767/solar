{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = false;
    useSecrets = false;
  };

  module =
    {
      lib,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      # Thebe: Intel Mac Mini (Moon of Jupiter)
      myFeatures = {
        # 🌲 Dendritic Suites
        suites.server.enable = true;

        # 🎛️ Host Specifics
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = false;
            };
            disko = {
              enable = true;
              enableLuks = true;
              speedDisks = [ "/dev/sda" ];
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

        hardware = {
          cpu-gpu.intel.enable = true;
          peripherals = {
            bluetooth.enable = true;
            wifi = {
              enable = true;
              persistence = true;
            };
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

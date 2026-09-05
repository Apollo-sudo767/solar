{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = false;
  };

  module =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      myFeatures = {
        # 🌲 Dendritic Suites
        suites = {
          workstation.enable = true;
          desktops.cosmic.enable = true;
        };

        # 🎛️ Host Specifics
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = false;
            };
            disko = {
              enable = true;
              enableLuks = false;
              speedDisks = [ "/dev/nvme0n1" ];
            };
            users.usernames = [ "apollo" ];
          };
          boot = {
            enable = true;
            kernel = "latest";
          };
          security.security.useAppArmor = true;
        };

        platforms = {
          styling = {
            stylix.enable = true;
            themes.space.enable = true;
          };
          addons.displayManager.manager = "cosmic-greeter";
        };
      };
    };
}

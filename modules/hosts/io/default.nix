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
        core = {
          system = {
            core-branch.enable = true;
            disko.enable = false;
            users.usernames = [ "apollo" ];
          };
          security.security = {
            enable = true;
            useAppArmor = true;
          };
          nix.lix.enable = true;
          shell.shell-branch.enable = true;
          boot = {
            enable = true;
            kernel = "latest";
          };
        };
        platforms = {
          desktops.cosmic.enable = true;
          styling = {
            stylix.enable = true;
            themes.space.enable = true;
          };
          addons.displayManager.manager = "cosmic-greeter";
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
          browsers.firefox.enable = true;
          utilities = {
            bitwarden.enable = true;
            stylePackages.enable = true;
            filemanager.enable = true;
            vesktop.enable = true;
          };
        };
        services = {
          multimedia.audio.enable = true;
          system = {
            flatpak.enable = true;
            xdgPortals.enable = true;
          };
          hardware = {
            udisks2.enable = true;
          };
        };
        hardware = {
          system.graphics.enable = true;
        };
      };
    };
}

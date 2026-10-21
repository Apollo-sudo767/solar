# modules/programs/utilities/appstore/discover.nix
#
# Configures KDE Discover (Qt/Kirigami Flatpak software center) and state preservation on NixOS.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.appstore.discover;
in
{
  options.myFeatures.programs.utilities.appstore.discover = {
    enable = lib.mkEnableOption "KDE Discover (Qt/Kirigami Flatpak store)";
  };

  config = lib.mkIf cfg.enable {
    # Ensure Flatpak subsystem is active so Discover can manage apps
    myFeatures.services.system.flatpak.enable = lib.mkDefault true;

    environment.systemPackages = [
      pkgs.kdePackages.discover
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/discover"
              ".cache/discover"
            ];
          });
        };
  };
}

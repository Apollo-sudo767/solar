# modules/platforms/desktops/mate.nix
#
# Configures the MATE X11 desktop environment and state preservation on NixOS.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.mate;
in
{
  options.myFeatures.platforms.desktops.mate = {
    enable = lib.mkEnableOption "MATE Desktop Environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager.mate.enable = true;
    };

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/mate"
              ".local/share/mate"
            ];
          });
        };
  };
}

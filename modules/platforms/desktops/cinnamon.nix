{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.cinnamon;
in
{
  options.myFeatures.platforms.desktops.cinnamon = {
    enable = lib.mkEnableOption "Cinnamon Desktop Environment";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager.cinnamon.enable = true;
    };

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/cinnamon"
              ".local/share/cinnamon"
            ];
          });
        };
  };
}

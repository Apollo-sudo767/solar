{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.budgie;
in
{
  options.myFeatures.platforms.desktops.budgie = {
    enable = lib.mkEnableOption "Budgie Desktop Environment";
  };

  config = lib.mkIf (cfg.enable) {
    services.xserver = {
      enable = true;
      desktopManager.budgie.enable = true;
    };

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/budgie-desktop"
            ];
          });
        };
  };
}

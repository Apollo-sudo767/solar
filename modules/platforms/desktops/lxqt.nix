{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.lxqt;
in
{
  options.myFeatures.platforms.desktops.lxqt = {
    enable = lib.mkEnableOption "LXQt Lightweight Qt Desktop Environment";
  };

  config = lib.mkIf (cfg.enable) {
    services.xserver = {
      enable = true;
      desktopManager.lxqt.enable = true;
    };

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/lxqt"
            ];
          });
        };
  };
}

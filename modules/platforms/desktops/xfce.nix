{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.xfce;
in
{
  options.myFeatures.platforms.desktops.xfce = {
    enable = lib.mkEnableOption "XFCE Desktop Environment";
  };

  config = lib.mkIf (cfg.enable) {
    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
    };

    environment.systemPackages = with pkgs.xfce; [
      xfce4-whiskermenu-plugin
      xfce4-pulseaudio-plugin
      xfce4-clipman-plugin
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/xfce4"
              ".local/share/xfce4"
            ];
          });
        };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.openbox;
in
{
  options.myFeatures.platforms.desktops.openbox = {
    enable = lib.mkEnableOption "Openbox (Classic Lightweight X11 Stacking Window Manager)";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager.openbox.enable = true;
    };

    environment.systemPackages = with pkgs; [
      tint2
      feh
      picom
      dmenu
      obconf
      xclip
      libnotify
      brightnessctl
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/openbox"
            ];
          });
        };
  };
}

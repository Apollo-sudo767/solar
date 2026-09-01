{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.xmonad;
in
{
  options.myFeatures.platforms.desktops.xmonad = {
    enable = lib.mkEnableOption "XMonad (Haskell-extensible Dynamic X11 Tiling Window Manager)";

    enableContribAndExtras = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable xmonad-contrib and xmonad-extras libraries";
    };

    configGhc = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra Haskell configuration lines";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager.xmonad = {
        enable = true;
        inherit (cfg) enableContribAndExtras;
      };
    };

    environment.systemPackages = with pkgs; [
      dmenu
      xmobar
      feh
      picom
      xclip
      libnotify
      brightnessctl
    ];

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xsession.windowManager.xmonad = {
        enable = true;
        inherit (cfg) enableContribAndExtras;
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".xmonad"
            ];
          });
        };
  };
}

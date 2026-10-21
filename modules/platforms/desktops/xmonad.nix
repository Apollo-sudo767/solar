# modules/platforms/desktops/xmonad.nix
# ============================================================================
# XMonad Dynamic X11 Tiling Window Manager
# ============================================================================
# Configures XMonad on X11 with `xmonad-contrib` and `xmonad-extras`, companion
# X11 utilities (`xmobar`, `dmenu`, `picom`, `feh`), optional custom Haskell
# configuration lines (`configGhc`), and `~/.xmonad` preservation.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.xmonad;
  customConfig = lib.concatStringsSep "\n" cfg.configGhc;
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
      description = "Extra Haskell configuration lines for xmonad.hs";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager.xmonad = {
        enable = true;
        inherit (cfg) enableContribAndExtras;
        config = lib.mkIf (cfg.configGhc != [ ]) customConfig;
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
        config = lib.mkIf (cfg.configGhc != [ ]) (pkgs.writeText "xmonad.hs" customConfig);
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

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.bspwm;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable or false;
in
{
  options.myFeatures.platforms.desktops.bspwm = {
    enable = lib.mkEnableOption "Bspwm (Binary Space Partitioning X11 Tiling Window Manager)";

    borderWidth = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Window border width in pixels";
    };

    windowGap = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Window gap in pixels";
    };

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra shell lines appended to bspwmrc";
    };
  };

  config = lib.mkIf (cfg.enable) {
    services.xserver = {
      enable = true;
      windowManager.bspwm.enable = true;
    };

    environment.systemPackages = with pkgs; [
      sxhkd
      dmenu
      feh
      picom
      xclip
      libnotify
      brightnessctl
    ];

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xsession.windowManager.bspwm = {
        enable = true;
        monocle_padding = 0;
        settings = {
          border_width = cfg.borderWidth;
          window_gap = cfg.windowGap;
          split_ratio = 0.52;
          borderless_monocle = true;
          gapless_monocle = true;
          normal_border_color =
            if stylixEnabled then "#${config.lib.stylix.colors.base02}" else "#4c566a";
          focused_border_color =
            if stylixEnabled then "#${config.lib.stylix.colors.base0D}" else "#88c0d0";
        };
        extraConfig = lib.concatStringsSep "\n" cfg.extraConfig;
      };

      services.sxhkd = {
        enable = true;
        keybindings = {
          "super + q" = "ghostty";
          "super + shift + q" = "firefox";
          "super + space" = "dmenu_run";
          "super + d" = "dmenu_run";
          "super + c" = "bspc node -c";
          "super + shift + e" = "bspc quit";
          "super + f" = "bspc node -t fullscreen";
          "super + v" = "bspc node -t floating";

          # Focus/Swap
          "super + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
          "super + shift + {h,j,k,l}" = "bspc node -s {west,south,north,east}";

          # Workspaces
          "super + {1-9}" = "bspc desktop -f '^{1-9}'";
          "super + shift + {1-9}" = "bspc node -d '^{1-9}'";
        };
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/bspwm"
              ".config/sxhkd"
            ];
          });
        };
  };
}

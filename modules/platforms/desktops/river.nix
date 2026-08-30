{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.river;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable or false;
in
{
  options.myFeatures.platforms.desktops.river = {
    enable = lib.mkEnableOption "River Dynamic Tiling Wayland Compositor";

    modKey = lib.mkOption {
      type = lib.types.enum [
        "Super"
        "Alt"
      ];
      default = "Super";
      description = "Primary modifier key for River bindings";
    };

    borderWidth = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Border width in pixels";
    };

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra shell commands executed in river init script";
    };
  };

  config = lib.mkIf (cfg.enable) {
    programs.river = {
      enable = true;
      extraPackages = with pkgs; [
        rivertile
        wl-clipboard
        libnotify
        brightnessctl
        fuzzel
        swaybg
        swayidle
        swaylock
        grim
        slurp
      ];
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      config.river.default = [
        "wlr"
        "gtk"
      ];
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      wayland.windowManager.river = {
        enable = true;
        settings = {
          border_width = cfg.borderWidth;
          border_color_focused =
            if stylixEnabled then "0x${config.lib.stylix.colors.base0D}" else "0x78a9ffff";
          border_color_unfocused =
            if stylixEnabled then "0x${config.lib.stylix.colors.base02}" else "0x504945ff";
          declare_mode = [ "normal" ];
          map = {
            normal = {
              "${cfg.modKey} Q" = "spawn ghostty";
              "${cfg.modKey}+Shift Q" = "spawn firefox";
              "${cfg.modKey} Space" = "spawn fuzzel";
              "${cfg.modKey} D" = "spawn fuzzel";
              "${cfg.modKey} C" = "close";
              "${cfg.modKey}+Shift E" = "exit";
              "${cfg.modKey} F" = "toggle-fullscreen";
              "${cfg.modKey} V" = "toggle-float";

              # Focus
              "${cfg.modKey} J" = "focus-view next";
              "${cfg.modKey} K" = "focus-view previous";
              "${cfg.modKey} Down" = "focus-view next";
              "${cfg.modKey} Up" = "focus-view previous";

              # Swap
              "${cfg.modKey}+Shift J" = "swap next";
              "${cfg.modKey}+Shift K" = "swap previous";

              # Layout controls
              "${cfg.modKey} H" = "send-layout-cmd rivertile 'main-ratio -0.05'";
              "${cfg.modKey} L" = "send-layout-cmd rivertile 'main-ratio +0.05'";
            };
          };
          spawn = [
            "rivertile -view-padding 4 -outer-padding 8"
          ];
        };
        extraConfig = lib.concatStringsSep "\n" cfg.extraConfig;
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/river"
            ];
          });
        };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.i3;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable or false;
in
{
  options.myFeatures.platforms.desktops.i3 = {
    enable = lib.mkEnableOption "i3 X11 Tiling Window Manager";

    modKey = lib.mkOption {
      type = lib.types.enum [
        "Mod4"
        "Mod1"
      ];
      default = "Mod4";
      description = "Primary modifier key for i3 (Mod4 = Super, Mod1 = Alt)";
    };

    gapsInner = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Inner window gaps in pixels";
    };

    gapsOuter = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Outer window gaps in pixels";
    };

    borderWidth = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Window border width in pixels";
    };

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra raw configuration lines appended to i3 config";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      windowManager.i3.enable = true;
    };

    environment.systemPackages = with pkgs; [
      dmenu
      i3status
      i3lock
      xclip
      feh
      picom
      libnotify
      brightnessctl
    ];

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xsession.windowManager.i3 = {
        enable = true;
        config = {
          modifier = cfg.modKey;
          terminal = "ghostty";
          menu = "dmenu_run";

          gaps = {
            inner = cfg.gapsInner;
            outer = cfg.gapsOuter;
          };

          window = {
            border = cfg.borderWidth;
            titlebar = false;
          };

          keybindings =
            let
              mod = cfg.modKey;
            in
            lib.mkOptionDefault {
              "${mod}+q" = "exec ghostty";
              "${mod}+Shift+q" = "exec firefox";
              "${mod}+space" = "exec dmenu_run";
              "${mod}+d" = "exec dmenu_run";
              "${mod}+c" = "kill";
              "${mod}+Shift+e" = "exit";
              "${mod}+v" = "floating toggle";
              "${mod}+f" = "fullscreen toggle";

              # Focus
              "${mod}+Left" = "focus left";
              "${mod}+Right" = "focus right";
              "${mod}+Up" = "focus up";
              "${mod}+Down" = "focus down";
              "${mod}+h" = "focus left";
              "${mod}+l" = "focus right";
              "${mod}+k" = "focus up";
              "${mod}+j" = "focus down";

              # Move
              "${mod}+Shift+Left" = "move left";
              "${mod}+Shift+Right" = "move right";
              "${mod}+Shift+Up" = "move up";
              "${mod}+Shift+Down" = "move down";
              "${mod}+Shift+h" = "move left";
              "${mod}+Shift+l" = "move right";
              "${mod}+Shift+k" = "move up";
              "${mod}+Shift+j" = "move down";

              # Workspaces
              "${mod}+1" = "workspace number 1";
              "${mod}+2" = "workspace number 2";
              "${mod}+3" = "workspace number 3";
              "${mod}+4" = "workspace number 4";
              "${mod}+5" = "workspace number 5";
              "${mod}+6" = "workspace number 6";
              "${mod}+7" = "workspace number 7";
              "${mod}+8" = "workspace number 8";
              "${mod}+9" = "workspace number 9";

              # Move to Workspaces
              "${mod}+Shift+1" = "move container to workspace number 1";
              "${mod}+Shift+2" = "move container to workspace number 2";
              "${mod}+Shift+3" = "move container to workspace number 3";
              "${mod}+Shift+4" = "move container to workspace number 4";
              "${mod}+Shift+5" = "move container to workspace number 5";
              "${mod}+Shift+6" = "move container to workspace number 6";
              "${mod}+Shift+7" = "move container to workspace number 7";
              "${mod}+Shift+8" = "move container to workspace number 8";
              "${mod}+Shift+9" = "move container to workspace number 9";
            };

          colors = lib.mkIf stylixEnabled {
            focused = {
              border = "#${config.lib.stylix.colors.base0D}";
              background = "#${config.lib.stylix.colors.base0D}";
              text = "#${config.lib.stylix.colors.base00}";
              indicator = "#${config.lib.stylix.colors.base0E}";
              childBorder = "#${config.lib.stylix.colors.base0D}";
            };
            unfocused = {
              border = "#${config.lib.stylix.colors.base02}";
              background = "#${config.lib.stylix.colors.base01}";
              text = "#${config.lib.stylix.colors.base05}";
              indicator = "#${config.lib.stylix.colors.base02}";
              childBorder = "#${config.lib.stylix.colors.base02}";
            };
          };
        };

        extraConfig = lib.concatStringsSep "\n" cfg.extraConfig;
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/i3"
            ];
          });
        };
  };
}

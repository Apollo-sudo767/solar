{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.wayfire;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable or false;
in
{
  options.myFeatures.platforms.desktops.wayfire = {
    enable = lib.mkEnableOption "Wayfire 3D Compiz-style Wayland Compositor";

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];
      description = "List of Wayfire plugins to install";
    };

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra configuration lines for wayfire.ini";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wayfire = {
      enable = true;
      inherit (cfg) plugins;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      libnotify
      brightnessctl
      fuzzel
      grim
      slurp
      wf-recorder
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
      config.wayfire.default = [
        "wlr"
        "gtk"
      ];
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      wayland.windowManager.wayfire = {
        enable = true;
        inherit (cfg) plugins;
        settings = {
          core = {
            plugins = "alpha animate autostart command cube expo fast-switcher fisheye grid idle move osd place resize switcher vswitch window-rules wobbly wrot zoom";
            close_top_view = "<super> KEY_C";
            focus_button_with_modifiers = false;
          };

          command = {
            binding_terminal = "<super> KEY_Q";
            command_terminal = "ghostty";
            binding_launcher = "<super> KEY_SPACE";
            command_launcher = "fuzzel";
            binding_browser = "<super> <shift> KEY_Q";
            command_browser = "firefox";
          };

          cube = {
            activate = "<super> <ctrl> BTN_LEFT";
          };

          wobbly = {
            spring_k = 8;
            friction = 0.8;
          };

          animate = {
            open_animation = "zoom";
            close_animation = "zoom";
            duration = 300;
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
              ".config/wayfire"
            ];
          });
        };
  };
}

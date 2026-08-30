{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.hyprland;
  stylixEnabled = config.myFeatures.platforms.styling.stylix.enable or false;
in
{
  options.myFeatures.platforms.desktops.hyprland = {
    enable = lib.mkEnableOption "Hyprland Dynamic Tiling Wayland Compositor";

    modKey = lib.mkOption {
      type = lib.types.enum [
        "SUPER"
        "ALT"
      ];
      default = "SUPER";
      description = "Primary modifier key for Hyprland bindings";
    };

    gapsIn = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Inner gaps between windows in pixels";
    };

    gapsOut = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Outer gaps between windows and monitor edges in pixels";
    };

    borderSize = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Window border size in pixels";
    };

    rounding = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Corner rounding radius in pixels";
    };

    blur = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable background blur for transparent surfaces";
    };

    shadow = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable window drop shadows";
    };

    animations = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable window and workspace animations";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Monitor output connector name (e.g. DP-1, HDMI-A-1, eDP-1)";
              example = "DP-1";
            };
            resolution = lib.mkOption {
              type = lib.types.str;
              default = "preferred";
              description = "Resolution string (e.g. 1920x1080, 2560x1440, preferred, highres)";
            };
            refresh = lib.mkOption {
              type = lib.types.nullOr (lib.types.either lib.types.float lib.types.int);
              default = null;
              description = "Refresh rate in Hz";
            };
            position = lib.mkOption {
              type = lib.types.str;
              default = "auto";
              description = "Position in logical layout (e.g. 0x0, 1920x0, auto)";
            };
            scale = lib.mkOption {
              type = lib.types.either lib.types.float lib.types.int;
              default = 1.0;
              description = "Display scaling factor";
            };
            vrr = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable variable refresh rate (Adaptive Sync)";
            };
          };
        }
      );
      default = [ ];
      description = "Declarative list of display monitors for Hyprland";
    };

    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra raw configuration lines appended to hyprland.conf";
    };
  };

  config = lib.mkIf (cfg.enable) {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment.systemPackages = with pkgs; [
      wl-clipboard
      libnotify
      brightnessctl
      grim
      slurp
      hyprshot
    ];

    # XDG desktop portal for Hyprland
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      config.hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      wayland.windowManager.hyprland = {
        enable = true;
        settings = {
          "$mod" = cfg.modKey;

          # Monitors
          monitor =
            if cfg.monitors != [ ] then
              map (
                m:
                let
                  modeStr =
                    if m.refresh != null then
                      "${m.resolution}@${toString (m.refresh * 1.0)}"
                    else
                      m.resolution;
                  vrrFlag = if m.vrr then ",vrr,1" else "";
                in
                "${m.name},${modeStr},${m.position},${toString (m.scale * 1.0)}${vrrFlag}"
              ) cfg.monitors
            else
              [ ",preferred,auto,1" ];

          # General appearance
          general = {
            gaps_in = cfg.gapsIn;
            gaps_out = cfg.gapsOut;
            border_size = cfg.borderSize;
            "col.active_border" =
              if stylixEnabled then
                "rgb(${config.lib.stylix.colors.base0D}) rgb(${config.lib.stylix.colors.base0E}) 45deg"
              else
                "rgba(33ccffee) rgba(00ff99ee) 45deg";
            "col.inactive_border" =
              if stylixEnabled then
                "rgb(${config.lib.stylix.colors.base02})"
              else
                "rgba(595959aa)";
            layout = "dwindle";
            allow_tearing = false;
          };

          # Decoration & Visuals
          decoration = {
            rounding = cfg.rounding;
            active_opacity = 1.0;
            inactive_opacity = 0.95;
            drop_shadow = cfg.shadow;
            shadow_range = 24;
            shadow_render_power = 3;
            "col.shadow" = "rgba(00000066)";
            blur = {
              enabled = cfg.blur;
              size = 6;
              passes = 2;
              new_optimizations = true;
              xray = true;
            };
          };

          # Animations
          animations = {
            enabled = cfg.animations;
            bezier = [
              "overshoot, 0.05, 0.9, 0.1, 1.05"
              "smoothOut, 0.36, 0, 0.66, -0.56"
              "smoothIn, 0.25, 1, 0.5, 1"
            ];
            animation = [
              "windows, 1, 4, overshoot, slide"
              "windowsOut, 1, 4, smoothOut, slide"
              "border, 1, 8, default"
              "fade, 1, 4, smoothIn"
              "workspaces, 1, 5, default, slide"
            ];
          };

          # Layouts
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          # Input
          input = {
            kb_layout = "us";
            follow_mouse = 1;
            touchpad = {
              natural_scroll = true;
              tap-to-click = true;
            };
            sensitivity = 0;
          };

          # Keybindings
          bind = [
            # Applications
            "$mod, Q, exec, ghostty"
            "$mod SHIFT, Q, exec, firefox"
            "$mod, SPACE, exec, fuzzel"
            "$mod, D, exec, fuzzel"
            "$mod, C, killactive,"
            "$mod SHIFT, E, exit,"
            "$mod, V, togglefloating,"
            "$mod, F, fullscreen, 0"
            "$mod, M, fullscreen, 1"

            # Window Focus (Arrows & Vim keys)
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"
            "$mod, H, movefocus, l"
            "$mod, L, movefocus, r"
            "$mod, K, movefocus, u"
            "$mod, J, movefocus, d"

            # Window Movement
            "$mod CTRL, left, movewindow, l"
            "$mod CTRL, right, movewindow, r"
            "$mod CTRL, up, movewindow, u"
            "$mod CTRL, down, movewindow, d"
            "$mod CTRL, H, movewindow, l"
            "$mod CTRL, L, movewindow, r"
            "$mod CTRL, K, movewindow, u"
            "$mod CTRL, J, movewindow, d"

            # Workspaces
            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"
            "$mod, 8, workspace, 8"
            "$mod, 9, workspace, 9"

            # Move active window to workspace
            "$mod SHIFT, 1, movetoworkspace, 1"
            "$mod SHIFT, 2, movetoworkspace, 2"
            "$mod SHIFT, 3, movetoworkspace, 3"
            "$mod SHIFT, 4, movetoworkspace, 4"
            "$mod SHIFT, 5, movetoworkspace, 5"
            "$mod SHIFT, 6, movetoworkspace, 6"
            "$mod SHIFT, 7, movetoworkspace, 7"
            "$mod SHIFT, 8, movetoworkspace, 8"
            "$mod SHIFT, 9, movetoworkspace, 9"

            # Screenshots
            ", Print, exec, hyprshot -m region"
            "CTRL, Print, exec, hyprshot -m output"
            "ALT, Print, exec, hyprshot -m window"
          ];

          # Mouse drag / resize
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
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
              ".config/hypr"
              ".cache/mesa_shader_cache"
            ];
          });
        };
  };
}

{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  options.myFeatures.platforms.desktops.niri = {
    defaultColumnWidth = lib.mkOption {
      type = lib.types.nullOr lib.types.float;
      default = null;
      description = "Default column width proportion for Niri layout (e.g. 1.0 for 100%, 0.5 for 50%)";
      example = 1.0;
    };
    presetColumnWidths = lib.mkOption {
      type = lib.types.listOf lib.types.float;
      default = [
        0.33333
        0.5
        0.66667
        1.0
      ];
      description = "Preset column widths proportions for cycling with switch-preset-column-width";
    };
    gaps = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Gaps around windows in logical pixels";
      example = 12;
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      prefer-no-csd = { };

      layout = {
        default-column-width =
          if cfg.defaultColumnWidth != null then
            { proportion = cfg.defaultColumnWidth; }
          else
            lib.mkDefault { proportion = 0.5; };
        preset-column-widths._children = lib.mkDefault (
          map (p: { proportion = p; }) cfg.presetColumnWidths
        );
        background-color = lib.mkDefault "transparent";
        gaps = lib.mkDefault cfg.gaps;
        focus-ring.off = lib.mkDefault { };
        border = lib.mkDefault {
          width = 2;
          active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
          inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
        };
        tab-indicator = {
          hide-when-single-tab = { };
          place-within-column = { };
          gap = 4;
          width = 4;
          position = "right";
          corner-radius = 2.0;
          active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
          inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
        };
        shadow = {
          on = { };
          softness = 24;
          spread = 4;
          offset._props = {
            x = 0;
            y = 5;
          };
          color = "rgba(0, 0, 0, 0.45)";
          inactive-color = "rgba(0, 0, 0, 0.25)";
        };
      };

      animations = {
        workspace-switch = {
          spring._props = {
            damping-ratio = 0.85;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };
        horizontal-view-movement = {
          spring._props = {
            damping-ratio = 0.9;
            stiffness = 900;
            epsilon = 0.0001;
          };
        };
        window-open = {
          duration-ms = 150;
          curve = "ease-out-expo";
        };
        window-close = {
          duration-ms = 120;
          curve = "ease-out-quad";
        };
        window-movement = {
          spring._props = {
            damping-ratio = 0.85;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };
        window-resize = {
          spring._props = {
            damping-ratio = 0.85;
            stiffness = 800;
            epsilon = 0.0001;
          };
        };
      };

      recent-windows = {
        debounce-ms = 750;
        open-delay-ms = 150;
        highlight = {
          active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
          urgent-color = if config.stylix.enable then "#${config.lib.stylix.colors.base08}" else "#fb4934";
          padding = 24;
          corner-radius = 10.0;
        };
        previews = {
          max-height = 480;
          max-scale = 0.5;
        };
        binds = {
          "Alt+Tab".next-window = { };
          "Alt+Shift+Tab".previous-window = { };
          "Alt+grave" = {
            next-window._props = {
              filter = "app-id";
            };
          };
          "Alt+Shift+grave" = {
            previous-window._props = {
              filter = "app-id";
            };
          };
          "Mod+Tab".next-window = { };
          "Mod+Shift+Tab".previous-window = { };
          "Mod+grave" = {
            next-window._props = {
              filter = "app-id";
            };
          };
          "Mod+Shift+grave" = {
            previous-window._props = {
              filter = "app-id";
            };
          };
        };
      };

      _children = [
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "noctalia-bar-default";
              };
            }
            {
              background-effect = {
                blur = true;
                xray = true;
              };
            }
          ];
        }
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "^wallpaper$";
              };
            }
            { place-within-backdrop = true; }
          ];
        }
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "^noctalia-wallpaper$";
              };
            }
            { place-within-backdrop = true; }
          ];
        }
        {
          layer-rule._children = [
            {
              match._props = {
                namespace = "^noctalia-overview$";
              };
            }
            { place-within-backdrop = true; }
          ];
        }
        {
          window-rule._children = [
            { focus-ring.off = { }; }
            {
              geometry-corner-radius = 10;
              clip-to-geometry = true;
            }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "^(1Password|org.keepassxc.KeePassXC|bitwarden|org.gnome.World.Secrets)$";
              };
            }
            { block-out-from = "screen-capture"; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                title = "^Picture-in-Picture$";
              };
            }
            { open-floating = true; }
            {
              default-floating-position._props = {
                x = 24;
                y = 24;
                relative-to = "bottom-right";
              };
            }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "^(pavucontrol|org.gnome.Calculator|blueman-manager|nm-connection-editor|com.github.wwmm.easyeffects|gnome-disks|polkit-gnome-authentication-agent-1|lxqt-policykit-agent|org.kde.polkit-kde-authentication-agent-1)$";
              };
            }
            { open-floating = true; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "firefox";
              };
            }
            { border.off = { }; }
            { focus-ring.off = { }; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "com.mitchellh.ghostty";
              };
            }
            {
              background-effect = {
                blur = true;
                xray = true;
              };
            }
            { draw-border-with-background = false; }
            { border.off = { }; }
            {
              focus-ring = {
                width = 2;
                active-color = if config.stylix.enable then "#${config.lib.stylix.colors.base0D}" else "#83a598";
                inactive-color = if config.stylix.enable then "#${config.lib.stylix.colors.base02}" else "#504945";
              };
            }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "^steam_app_";
              };
            }
            {
              match._props = {
                app-id = "^gamescope$";
              };
            }
            { open-fullscreen = true; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "^steam$";
                title = "^notificationtoasts_[0-9]+_desktop$";
              };
            }
            {
              default-floating-position._props = {
                x = 16;
                y = 16;
                relative-to = "bottom-right";
              };
            }
            { open-floating = true; }
            { open-focused = false; }
          ];
        }
      ];
    };
  };
}

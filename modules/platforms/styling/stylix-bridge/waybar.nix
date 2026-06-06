{
  config,
  lib,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.waybar;
  c = config.lib.stylix.colors;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        programs.waybar = {
          settings.mainBar.clock.calendar.format = {
            months = "<span color='#${c.base0D}'><b>{}</b></span>";
            days = "<span color='#${c.base05}'><b>{}</b></span>";
            weeks = "<span color='#${c.base0C}'><b>W{}</b></span>";
            weekdays = "<span color='#${c.base0A}'><b>{}</b></span>";
            today = "<span color='#${c.base08}'><b><u>{}</u></b></span>";
          };

          style = lib.mkForce ''
            @define-color bg0 #${c.base00};
            @define-color bg1 #${c.base01};
            @define-color bg2 #${c.base02};
            @define-color fg0 #${c.base05};
            @define-color blue #${c.base0D};
            @define-color red #${c.base08};
            @define-color green #${c.base0B};
            @define-color yellow #${c.base0A};
            @define-color purple #${c.base0E};
            @define-color aqua #${c.base0C};

            * {
              font-family: "${config.stylix.fonts.monospace.name}", "JetBrainsMono Nerd Font", monospace;
              font-size: 13px;
              font-weight: bold;
              min-height: 0;
              border: none;
              box-shadow: none;
            }

            window#waybar {
              background: transparent;
              color: @fg0;
            }

            #custom-power, #custom-lock, #custom-suspend, #custom-reboot, #custom-exit,
            #workspaces, #window, #custom-branding, #mpris, #idle_inhibitor,
            #backlight, #cpu, #memory, #disk, #network, #battery, #pulseaudio, #clock, #tray,
            #custom-media-prev, #custom-media-next {
              background-color: alpha(@bg0, 0.7);
              padding: 0 12px;
              margin: 4px 0;
              border-radius: 10px;
              border: 1px solid rgba(255, 255, 255, 0.1);
              transition: all 0.3s ease;
              min-height: 28px;
            }

            #window.empty,
            #mpris.empty,
            #custom-media-prev.empty,
            #custom-media-next.empty {
              padding: 0;
              margin: 0;
              border: none;
              background: transparent;
            }

            #custom-power:hover, #custom-lock:hover, #custom-suspend:hover,
            #custom-reboot:hover, #custom-exit:hover, #workspaces button:hover,
            #idle_inhibitor:hover, #network:hover, #battery:hover,
            #pulseaudio:hover, #clock:hover, #custom-media-prev:hover, #custom-media-next:hover {
              background-color: @bg2;
              border: 1px solid @blue;
            }

            #custom-power { color: @red; }
            #workspaces button.focused { color: @blue; background-color: rgba(255, 255, 255, 0.1); }
            #workspaces button.urgent { color: @red; }
            #window { color: @aqua; }
            #custom-branding { color: @purple; }
            #mpris { color: @blue; }
            #cpu { color: @green; }
            #memory { color: @yellow; }
            #disk { color: @aqua; }
            #network { color: @purple; }
            #battery { color: @green; }
            #battery.warning { color: @yellow; }
            #battery.critical { color: @red; }
            #pulseaudio { color: @blue; }
            #clock { color: @fg0; }

            tooltip {
              background: @bg1;
              border-radius: 10px;
              border: 2px solid @blue;
            }

            tooltip label {
              color: @fg0;
              padding: 8px;
            }
          '';
        };
      }
    ];
  };
}

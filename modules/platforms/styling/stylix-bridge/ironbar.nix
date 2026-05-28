{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.addons.ironbar;
  c = config.lib.stylix.colors;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        programs.ironbar.style = lib.mkForce ''
          @define-color bg0 #${c.base00};
          @define-color bg1 #${c.base01};
          @define-color fg #${c.base05};
          @define-color blue #${c.base0D};
          @define-color red #${c.base08};
          @define-color green #${c.base0B};
          @define-color yellow #${c.base0A};

          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 11px;
            transition: none;
            border-radius: 0;
            border: none;
          }

          .background {
            background-color: @bg0;
            color: @fg;
            border-top: 2px solid @blue;
          }

          .power-menu {
            background-color: @red;
            color: @bg0;
            padding: 0 10px;
          }

          .workspaces button {
            padding: 0 10px;
            color: @fg;
          }

          .workspaces button.focused {
            background-color: @blue;
            color: @bg0;
          }

          .workspaces button.urgent {
            background-color: @red;
            color: @bg0;
          }

          .music {
            color: @blue;
            padding: 0 10px;
          }

          .focused {
            color: @blue;
            padding: 0 10px;
          }

          .sys_info {
            padding: 0 10px;
          }

          .volume {
            color: @yellow;
            padding: 0 10px;
          }

          .clock {
            color: @fg;
            padding: 0 10px;
          }

          .menu, .launcher, .clipboard, .notifications, .battery {
            padding: 0 10px;
          }

          .tray {
            padding: 0 5px;
          }
        '';
      }
    ];
  };
}

{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.addons.swaync;
  c = config.lib.stylix.colors;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        services.swaync.style = lib.mkForce ''
          @define-color bg0 #${c.base00};
          @define-color bg1 #${c.base01};
          @define-color fg #${c.base05};
          @define-color blue #${c.base0D};
          @define-color red #${c.base08};

          * {
            font-family: "JetBrainsMono Nerd Font";
            font-size: 11px;
          }

          .notification-row {
            outline: none;
            margin: 10px;
            padding: 0;
          }

          .notification-row:focus,
          .notification-row:hover {
            background: @bg1;
          }

          .notification {
            border-radius: 0;
            margin: 0;
            padding: 10px;
            background: @bg0;
            color: @fg;
            border: 2px solid @blue;
          }

          .control-center {
            background: @bg0;
            color: @fg;
            border: 2px solid @blue;
            border-radius: 0;
          }
        '';
      }
    ];
  };
}

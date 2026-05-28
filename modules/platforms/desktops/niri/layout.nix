{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      layout = {
        gaps = 0;
        focus-ring = {
          enable = lib.mkForce false;
          width = lib.mkForce 0;
        };
        border = {
          enable = true;
          width = 2;
          active.color = "#${config.lib.stylix.colors.base0D}";
          inactive.color = "#${config.lib.stylix.colors.base02}";
        };
      };
      window-rules = [
        {
          focus-ring.enable = false;
        }
        {
          matches = [ { app-id = "firefox"; } ];
          border.enable = false;
          focus-ring.enable = false;
        }
      ];
      prefer-no-csd = true;
    };
  };
}

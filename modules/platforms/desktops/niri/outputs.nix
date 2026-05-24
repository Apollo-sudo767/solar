{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      outputs = {
        "DP-1" = {
          mode = "2560x1440@180.0";
          position = {
            x = 0;
            y = 0;
          };
        };
        "DP-2" = {
          mode = "1920x1080@165.0";
          position = {
            x = 2560;
            y = 0;
          };
        };
      };
    };
  };
}

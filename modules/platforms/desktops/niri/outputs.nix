{
  config,
  lib,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      outputs = {
        "DP-1" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 180.0;
          };
          position = {
            x = 0;
            y = 0;
          };
        };
        "DP-2" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 165.0;
          };
          position = {
            x = 2560;
            y = 0;
          };
        };
      };
    };
  };
}

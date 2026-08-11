{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      outputs = {
        "ASUSTek COMPUTER INC VG27WQ3B TALMTR031961" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 180.0;
          };
          position = {
            x = 0;
            y = 0;
          };
          variable-refresh-rate = true;
        };
        "ASUSTek COMPUTER INC VG278 LBLMQS200546" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 165.0;
          };
          position = {
            x = 2560;
            y = 0;
          };
          variable-refresh-rate = true;
        };
        "DP-4" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 180.0;
          };
          position = {
            x = 0;
            y = 0;
          };
          variable-refresh-rate = true;
        };
        "DP-5" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 165.0;
          };
          position = {
            x = 2560;
            y = 0;
          };
          variable-refresh-rate = true;
        };
      };
    };
  };
}

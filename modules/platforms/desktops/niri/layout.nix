{ config, lib, ... }:

let
  cfg = config.myFeatures.platforms.desktops.niri;
in
{
  config = lib.mkIf cfg.enable {
    myFeatures.platforms.desktops.niri.settings = {
      layout = {
        gaps = 0;
        focus-ring.enable = false;
        border.width = 0;
      };
      prefer-no-csd = true;
    };
  };
}

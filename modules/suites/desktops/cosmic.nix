{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.cosmic;
in
{
  options.myFeatures.suites.desktops.cosmic = {
    enable = lib.mkEnableOption "COSMIC Desktop Suite";
  };

  config = lib.mkIf (cfg.enable) {
    myFeatures = {
      platforms.desktops.cosmic.enable = true;

      services.multimedia.audio.enable = lib.mkDefault true;
    };
  };
}

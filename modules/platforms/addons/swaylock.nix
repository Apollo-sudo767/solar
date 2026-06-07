{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.swaylock;
in
{
  options.myFeatures.platforms.addons.swaylock.enable = lib.mkEnableOption "swaylock screen locker";

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        programs.swaylock = {
          enable = true;
          package = pkgs.swaylock-effects;
          settings = {
            scaling = "fill";
            screenshots = true;
            clock = true;
            indicator = true;
            indicator-radius = 100;
            indicator-thickness = 7;
            effect-blur = "7x5";
          };
        };
      }
    ];
  };
}

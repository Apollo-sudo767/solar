{
  config,
  lib,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.chrome;
in
{
  config = lib.mkIf (cfg.enable && config.stylix.enable) {
    home-manager.sharedModules = [
      {
        stylix.targets.chromium.enable = true;
      }
    ];
  };
}

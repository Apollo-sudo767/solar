{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  config = lib.mkIf (cfg.manager == "gdm") {
    services.xserver.displayManager.gdm.enable = true;
  };
}

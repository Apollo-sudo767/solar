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
  config = lib.mkIf (cfg.manager == "sddm") {
    services.displayManager.sddm.wayland.enable = true;
  };
}

{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  options.myFeatures.platforms.addons.displayManager = {
    manager = lib.mkOption {
      type = lib.types.enum [
        "tuigreet"
        "gdm"
        "sddm"
        "gtkGreet"
        "regreet"
        "none"
      ];
      default = "none";
    };
  };

  # The branch module itself doesn't need a mkIf cfg.enable because
  # it's just a router. Each leaf module has lib.mkIf (cfg.manager == "...")
}

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
  options.myFeatures.platforms.addons.displayManager = {
    manager = lib.mkOption {
      type = lib.types.enum [
        "tuigreet"
        "gdm"
        "sddm"
        "gtkGreet"
        "none"
      ];
      default = "none";
    };
  };

  config = lib.mkIf (cfg.manager != "none") {
    services.greetd = {
      enable = lib.mkIf (cfg.manager == "tuigreet" || cfg.manager == "gtkGreet") true;
      settings = lib.mkMerge [
        (lib.mkIf (cfg.manager == "tuigreet") {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --container-padding 2 --width 60 --cmd niri-session";
            user = "greeter";
          };
        })
      ];
    };
    services.xserver.displayManager.gdm.enable = lib.mkIf (cfg.manager == "gdm") true;
    services.displayManager.sddm.wayland.enable = lib.mkIf (cfg.manager == "sddm") true;
  };
}

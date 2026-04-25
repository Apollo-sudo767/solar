{ config, lib, pkgs, isDarwin, ... }: # <-- Add isDarwin

let
  cfg = config.myFeatures.systems.displayManager;
in
{
  options.myFeatures.systems.displayManager = {
    manager = lib.mkOption {
      type = lib.types.enum [ "tuigreet" "gdm" "sddm" "gtkGreet" "none" ];
      default = "none";
      description = "Which display manager to use.";
    };
  };

  # Shield the whole block
  config = lib.mkIf (cfg.manager != "none") (lib.optionalAttrs (!isDarwin) {
    services.greetd = {
      enable = lib.mkIf (cfg.manager == "tuigreet" || cfg.manager == "gtkGreet") true;
      settings = lib.mkMerge [
        (lib.mkIf (cfg.manager == "tuigreet") {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --container-padding 2 --width 60 --cmd niri-session"; 
            user = "greeter"; 
          };
        })
        (lib.mkIf (cfg.manager == "gtkGreet") {
          default_session = {
            command = "${pkgs.cage}/bin/cage -s -m last -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
            user = "greeter";
          };
        })
      ];
    };

    services.xserver.displayManager.gdm.enable = lib.mkIf (cfg.manager == "gdm") true; 
    services.displayManager.sddm.wayland.enable = lib.mkIf (cfg.manager == "sddm") true; 
  });
}

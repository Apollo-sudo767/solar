{ config, lib, pkgs, ... }:

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

  config = lib.mkIf (cfg.manager != "none") {
    # Consolidated greetd configuration
    services.greetd = {
      enable = lib.mkIf (cfg.manager == "tuigreet" || cfg.manager == "gtkGreet") true;
      settings = lib.mkMerge [
        # Tuigreet Logic
        (lib.mkIf (cfg.manager == "tuigreet") {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --container-padding 2 --width 60 --cmd niri-session"; 
            user = "greeter"; 
          };
        })
        # GtkGreet Logic
        (lib.mkIf (cfg.manager == "gtkGreet") {
          default_session = {
            command = "${pkgs.cage}/bin/cage -s -m last -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
            user = "greeter";
          };
        })
      ];
    };

    # GDM (Gnome) - Updated path to avoid 'generic' internal error in 25.11/unstable
    services.xserver.displayManager.gdm.enable = lib.mkIf (cfg.manager == "gdm") true; 

    # SDDM (Plasma) - Updated path for consistency
    services.displayManager.sddm.wayland.enable = lib.mkIf (cfg.manager == "sddm") true; 
  };
}

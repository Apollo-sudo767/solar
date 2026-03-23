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

  config = {
    # Tuigreet (Minimal TUI) [cite: 18, 19]
    services.greetd = lib.mkIf (cfg.manager == "tuigreet") {
      enable = true; 
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --container-padding 2 --cmd niri-session"; 
        user = "greeter"; 
      };
    };

    # gtkgreet
    services.greetd = lib.mkIf (cfg.manager == "gtkGreet" ) {
      enable = true;
      settings.default_session = {
        # 'cage' is a kiosk compositor that runs one app on one screen
        command = "${pkgs.cage}/bin/cage -s -m last -- ${pkgs.greetd.gtkgreet}/bin/gtkgreet -l";
        user = "greeter";
      };
    };
    
    # GDM (Gnome) [cite: 29]
    services.displayManager.gdm.enable = lib.mkIf (cfg.manager == "gdm") true; 

    # SDDM (Plasma) [cite: 24]
    services.displayManager.sddm.enable = lib.mkIf (cfg.manager == "sddm") true; 
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.displayManager;
in
{
  options.myFeatures.systems.displayManager = {
    manager = lib.mkOption {
      type = lib.types.enum [ "tuigreet" "gdm" "sddm" "none" ];
      default = "none";
      description = "Which display manager to use.";
    };
  };

  config = {
    # Tuigreet (Minimal TUI) [cite: 18, 19]
    services.greetd = lib.mkIf (cfg.manager == "tuigreet") {
      enable = true; [cite: 18]
      settings.default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session"; [cite: 19]
        user = "greeter"; [cite: 20]
      };
    };

    # GDM (Gnome) [cite: 29]
    services.displayManager.gdm.enable = lib.mkIf (cfg.manager == "gdm") true; [cite: 29]

    # SDDM (Plasma) [cite: 24]
    services.displayManager.sddm.enable = lib.mkIf (cfg.manager == "sddm") true; [cite: 24]
  };
}

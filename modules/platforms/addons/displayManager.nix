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
        "regreet"
        "none"
      ];
      default = "none";
    };
  };

  config = lib.mkIf (cfg.manager != "none") {
    programs.regreet.enable = lib.mkIf (cfg.manager == "regreet") true;
    services.greetd = {
      enable = lib.mkIf (
        cfg.manager == "tuigreet" || cfg.manager == "gtkGreet" || cfg.manager == "regreet"
      ) true;
      settings = lib.mkMerge [
        (lib.mkIf (cfg.manager == "tuigreet") {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --container-padding 2 --width 60 --cmd niri-session";
            user = "greeter";
          };
        })
        (lib.mkIf (cfg.manager == "regreet") {
          default_session = {
            command =
              let
                # We use sway instead of cage to easily disable the secondary monitor
                # and prevent stretching/mirroring issues.
                swayConfig = pkgs.writeText "greetd-sway-config" ''
                  output "DP-1" mode 2560x1440@180Hz position 0 0
                  output "DP-2" disable
                  exec "${pkgs.greetd-regreet}/bin/re-greeter; swaymsg exit"
                '';
              in
              "${pkgs.sway}/bin/sway --config ${swayConfig} --unsupported-gpu";
            user = "greeter";
          };
        })
      ];
    };
    services.displayManager.gdm.enable = lib.mkIf (cfg.manager == "gdm") true;
    services.displayManager.sddm.wayland.enable = lib.mkIf (cfg.manager == "sddm") true;

    # Stylix integration
    stylix.targets.regreet.enable = lib.mkIf (
      cfg.manager == "regreet" && config.myFeatures.platforms.styling.stylix.enable
    ) true;
  };
}

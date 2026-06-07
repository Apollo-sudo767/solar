{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  config = lib.mkIf (cfg.manager == "regreet") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        programs.regreet.enable = true;
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command =
                let
                  # We use sway instead of cage to easily disable the secondary monitor
                  # and prevent stretching/mirroring issues.
                  swayConfig = pkgs.writeText "greetd-sway-config" ''
                    output "DP-1" mode 2560x1440@180Hz position 0 0
                    output "DP-2" disable
                    exec "${pkgs.regreet}/bin/regreet; swaymsg exit"
                  '';
                in
                "${pkgs.sway}/bin/sway --config ${swayConfig} --unsupported-gpu";
              user = "greeter";
            };
          };
        };

        # Stylix integration (Centralized target enablement)
        stylix.targets.regreet.enable = lib.mkIf config.stylix.enable true;
      })
    ]
  );
}

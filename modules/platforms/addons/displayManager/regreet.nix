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
                  # We use sway to launch regreet. Using 'output *' ensures it works on all hosts
                  # regardless of their monitor names (DP-1 vs eDP-1).
                  swayConfig = pkgs.writeText "greetd-sway-config" ''
                    output * bg #000000 solid_color
                    exec "${pkgs.regreet}/bin/regreet; swaymsg exit"
                  '';
                in
                "${pkgs.sway}/bin/sway --config ${swayConfig} --unsupported-gpu";
              user = "greeter";
            };
          };
        };

        # Stylix integration: Enabled to ensure a consistent theme (prevents white screen)
        stylix.targets.regreet.enable = true;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [
                "/var/lib/greetd"
                "/var/cache/regreet"
              ];
            };
      })
    ]
  );
}

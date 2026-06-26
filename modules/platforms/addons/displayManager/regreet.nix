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
                    exec "${pkgs.regreet}/bin/regreet; ${pkgs.sway}/bin/swaymsg exit"
                  '';
                  greetdSession = pkgs.writeShellScript "greetd-session" ''
                    export WLR_NO_HARDWARE_CURSORS=1
                    export WLR_RENDERER=pixman
                    export WLR_DRM_NO_ATOMIC=1
                    export WLR_DRM_NO_MODIFIERS=1
                    export __GL_GSYNC_ALLOWED=0
                    export __GL_VRR_ALLOWED=0
                    export GTK_USE_PORTAL=0
                    exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --config ${swayConfig} --unsupported-gpu
                  '';
                in
                "${greetdSession}";
              user = "greeter";
            };
          };
        };

        # Ensure correct permissions for the greeter user on persistent directories
        systemd.tmpfiles.rules = [
          "d /var/lib/greetd 0750 greeter greetd - -"
          "d /var/lib/regreet 0755 greeter greeter - -"
          "d /var/cache/regreet 0750 greeter greetd - -"
          "Z /var/lib/greetd 0750 greeter greetd - -"
          "Z /var/lib/regreet 0755 greeter greeter - -"
          "Z /var/cache/regreet 0750 greeter greetd - -"
        ];

        # Stylix integration: Enabled to ensure a consistent theme (prevents white screen)
        stylix.targets.regreet.enable = true;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [
                "/var/lib/greetd"
                "/var/lib/regreet"
                "/var/cache/regreet"
              ];
            };
      })
    ]
  );
}

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
  config = lib.mkIf (cfg.manager == "tuigreet") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --container-padding 2 --width 60 --cmd niri-session";
              user = "greeter";
            };
          };
        };
      })
    ]
  );
}

{
  config,
  lib,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  config = lib.mkIf (cfg.manager == "cosmic-greeter") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.displayManager.cosmic-greeter.enable = true;
      })
    ]
  );
}

# modules/platforms/addons/displayManager/cosmic-greeter.nix
#
# Configures `cosmic-greeter` when selected via `myFeatures.platforms.addons.displayManager.manager`.
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

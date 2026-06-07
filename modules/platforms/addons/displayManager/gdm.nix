{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  config = lib.mkIf (cfg.manager == "gdm") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.xserver.displayManager.gdm.enable = true;
      })
    ]
  );
}

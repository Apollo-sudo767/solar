{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.platforms.addons.displayManager;
in
{
  config = lib.mkIf (cfg.manager == "sddm") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.displayManager.sddm.wayland.enable = true;
      })
    ]
  );
}

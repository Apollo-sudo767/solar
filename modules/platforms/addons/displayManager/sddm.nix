# modules/platforms/addons/displayManager/sddm.nix
#
# Configures SDDM (Simple Desktop Display Manager) when selected via `displayManager.manager`.
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
  config = lib.mkIf (cfg.manager == "sddm") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.displayManager.sddm.enable = true;
        services.displayManager.sddm.wayland.enable = lib.mkForce false;
      })
    ]
  );
}

# modules/platforms/addons/displayManager/gdm.nix
#
# Configures the GNOME Display Manager (GDM) when selected via `displayManager.manager`.
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
  config = lib.mkIf (cfg.manager == "gdm") (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        services.xserver.displayManager.gdm.enable = true;
      })
    ]
  );
}

# modules/programs/utilities/appstore/common.nix
# ============================================================================
# Graphical App Store Router
# ============================================================================
# Routes `myFeatures.programs.utilities.appstore`:
# - When `enable = true` (with `selection = null` or `"auto"`), automatically
#   enables KDE Discover on KDE Plasma desktops or GNOME Software on other
#   Linux desktops.
# - Explicit `selection` ("gnome-software", "discover", "both") enables the
#   requested graphical store(s) directly.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.appstore;
  isKde = config.myFeatures.platforms.desktops.kde.enable or false;
  autoMode = cfg.enable && (cfg.selection == null || cfg.selection == "auto");
in
{
  options.myFeatures.programs.utilities.appstore = {
    enable = lib.mkEnableOption "App Store & graphical flatpak store";

    selection = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "auto"
          "gnome-software"
          "discover"
          "both"
        ]
      );
      default = null;
      description = "Graphical app store selector ('auto', 'gnome-software', 'discover', or 'both').";
    };
  };

  config = lib.mkIf (cfg.enable || cfg.selection != null) {
    myFeatures.programs.utilities.appstore = {
      gnome-software.enable = lib.mkIf (
        cfg.selection == "gnome-software" || cfg.selection == "both" || (autoMode && !isKde)
      ) (lib.mkDefault true);
      discover.enable = lib.mkIf (
        cfg.selection == "discover" || cfg.selection == "both" || (autoMode && isKde)
      ) (lib.mkDefault true);
    };
  };
}

{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.appstore;
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
      description = "Optional legacy selector to enable a specific app store.";
    };
  };

  config = lib.mkIf (cfg.selection != null && cfg.selection != "auto") {
    myFeatures.programs.utilities.appstore = {
      gnome-software.enable = lib.mkIf (cfg.selection == "gnome-software" || cfg.selection == "both") (
        lib.mkDefault true
      );
      discover.enable = lib.mkIf (cfg.selection == "discover" || cfg.selection == "both") (
        lib.mkDefault true
      );
    };
  };
}

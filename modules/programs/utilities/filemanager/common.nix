# modules/programs/utilities/filemanager/common.nix
# ============================================================================
# File Manager Router
# ============================================================================
# Routes `myFeatures.programs.utilities.filemanager`:
# - On macOS (`isDarwin`): `enable = true` defaults to enabling Commander One.
# - On Linux (`!isDarwin`): `enable = true` (when `selection == null`) defaults
#   to Dolphin on KDE Plasma or Nautilus on other desktops, plus Yazi terminal
#   file manager. Setting `selection` explicitly enables the chosen backend.
{
  config,
  lib,
  isDarwin ? false,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager;
  isKde = config.myFeatures.platforms.desktops.kde.enable or false;
in
{
  options.myFeatures.programs.utilities.filemanager = {
    enable = lib.mkEnableOption "File Manager module";

    selection = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "thunar"
          "nautilus"
          "dolphin"
          "yazi"
          "nemo"
          "pcmanfm"
        ]
      );
      default = null;
      description = "Optional selector to enable a specific graphical or terminal file manager.";
    };
  };

  config = lib.mkMerge [
    # macOS default file manager
    (lib.mkIf (isDarwin && cfg.enable) {
      myFeatures.programs.utilities.filemanager.commander-one.enable = lib.mkDefault true;
    })

    # Linux automatic & explicit selection router
    (lib.optionalAttrs (!isDarwin) (
      lib.mkIf (cfg.enable || cfg.selection != null) {
        myFeatures.programs.utilities.filemanager = {
          nautilus.enable = lib.mkIf (
            cfg.selection == "nautilus" || (cfg.enable && cfg.selection == null && !isKde)
          ) (lib.mkDefault true);
          dolphin.enable = lib.mkIf (
            cfg.selection == "dolphin" || (cfg.enable && cfg.selection == null && isKde)
          ) (lib.mkDefault true);
          thunar.enable = lib.mkIf (cfg.selection == "thunar") (lib.mkDefault true);
          yazi.enable = lib.mkIf (cfg.selection == "yazi" || (cfg.enable && cfg.selection == null)) (
            lib.mkDefault true
          );
          nemo.enable = lib.mkIf (cfg.selection == "nemo") (lib.mkDefault true);
          pcmanfm.enable = lib.mkIf (cfg.selection == "pcmanfm") (lib.mkDefault true);
        };
      }
    ))
  ];
}

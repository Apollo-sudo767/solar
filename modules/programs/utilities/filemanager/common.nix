{
  config,
  lib,
  isDarwin ? false,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager;
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
      description = "Optional legacy selector to enable a specific file manager.";
    };
  };

  config = lib.mkMerge [
    # macOS fallback
    (lib.mkIf (isDarwin && cfg.enable) {
      myFeatures.programs.utilities.filemanager.commander-one.enable = lib.mkDefault true;
    })

    # Legacy selection mapper
    (lib.optionalAttrs (!isDarwin) (
      lib.mkIf (cfg.selection != null) {
        myFeatures.programs.utilities.filemanager = {
          nautilus.enable = lib.mkIf (cfg.selection == "nautilus") (lib.mkDefault true);
          dolphin.enable = lib.mkIf (cfg.selection == "dolphin") (lib.mkDefault true);
          thunar.enable = lib.mkIf (cfg.selection == "thunar") (lib.mkDefault true);
          yazi.enable = lib.mkIf (cfg.selection == "yazi") (lib.mkDefault true);
          nemo.enable = lib.mkIf (cfg.selection == "nemo") (lib.mkDefault true);
          pcmanfm.enable = lib.mkIf (cfg.selection == "pcmanfm") (lib.mkDefault true);
        };
      }
    ))
  ];
}

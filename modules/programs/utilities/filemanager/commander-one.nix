# modules/programs/utilities/filemanager/commander-one.nix
#
# Installs the Commander One dual-pane file manager via Homebrew cask on macOS.
{
  config,
  lib,
  isDarwin ? false,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.filemanager.commander-one;
in
{
  options.myFeatures.programs.utilities.filemanager.commander-one = {
    enable = lib.mkEnableOption "Commander One dual-pane file manager (macOS)";
  };

  config = lib.mkMerge [
    (lib.optionalAttrs isDarwin (
      lib.mkIf cfg.enable {
        homebrew.casks = [ "commander-one" ];
      }
    ))
  ];
}

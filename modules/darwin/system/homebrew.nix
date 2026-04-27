{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  ...
}:

let
  # 1. Setup a shortcut to your feature's config
  # Replace 'myFeature' with your actual feature name
  cfg = config.myFeatures.darwin.system.homebrew;
in
{
  # --- OPTIONS ---
  # This defines the "switches" you flip in your /hosts files
  options.myFeatures.darwin.system.homebrew = {
    enable = lib.mkEnableOption "Enable Homebrew";
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation.cleanup = "zap"; # Automatically uninstall apps you remove from this list!
      casks = [
        # Add your Mac-only GUI apps here
        "anytype"
        "ghostty"
      ];
    };
  };
}

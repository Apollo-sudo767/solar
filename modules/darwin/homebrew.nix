{ config, lib, pkgs, inputs, ... }:

let
  # 1. Setup a shortcut to your feature's config
  # Replace 'myFeature' with your actual feature name
  cfg = config.myFeatures.darwin.homebrew;
in
{
  # --- OPTIONS ---
  # This defines the "switches" you flip in your /hosts files
  options.myFeatures.darwin.homebrew = {
    enable = lib.mkEnableOption "Enable Homebrew";
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation.cleanup = "zap"; # Automatically uninstall apps you remove from this list!
      casks = [
        "arc"
        "raycast"
        "discord"
        # Add your Mac-only GUI apps here
      ];
    };
  };
}

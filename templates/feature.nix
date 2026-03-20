{ config, lib, pkgs, inputs, ... }:

let
  # 1. Setup a shortcut to your feature's config
  # Replace 'myFeature' with your actual feature name
  cfg = config.myFeatures.myFeature;

  # 2. Access stable packages if needed (via the flake inputs)
  pkgs-stable = import inputs.nixpkgs-stable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  # --- OPTIONS ---
  # This defines the "switches" you flip in your /hosts files
  options.myFeatures.myFeature = {
    enable = lib.mkEnableOption "Description of my feature";
    
    # Example of a custom setting (like a package override)
    exampleSetting = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable an extra sub-feature";
    };
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
  config = lib.mkIf cfg.enable {
    # System-level packages
    environment.systemPackages = with pkgs; [
      hello
      # inputs.zen-browser.packages.${pkgs.system}.default # Example of using a flake input
    ];

    # Conditional logic within the feature
    services.getty.helpLine = lib.mkIf cfg.exampleSetting "Extra help text enabled!";
  };
}

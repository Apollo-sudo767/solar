{ config, lib, pkgs, isDarwin, ... }:

{
  options.myFeatures.darwin.core = {
    enable = lib.mkEnableOption "Core macOS System Settings";
  };

  # The 'isDarwin' variable comes directly from our host loader!
  config = lib.mkIf (config.myFeatures.darwin.core.enable && isDarwin) {
    
    # --- Security ---
    security.pam.enableSudoTouchIdAuth = true;

    # --- System Defaults ---
    system.defaults = {
      # Dock settings
      dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;
        orientation = "bottom";
      };

      # Finder settings
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXPreferredViewStyle = "clmv"; # Column view
      };

      # Global macOS UI settings
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark"; # Force Dark Mode
        KeyRepeat = 2; # Fast key repeat
        InitialKeyRepeat = 15;
      };
    };
  };
}

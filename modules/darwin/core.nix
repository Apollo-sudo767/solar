{ config, lib, pkgs, isDarwin, ... }:

{
  options.myFeatures.darwin.core = {
    enable = lib.mkEnableOption "Core macOS System Settings";
  };

  config = lib.mkIf (config.myFeatures.darwin.core.enable && isDarwin) {
    
    # CRITICAL: Tell nix-darwin to let Determinate handle the Nix daemon
    nix.enable = false;

    # --- Security ---
    security.pam.services.sudo_local.touchIdAuth = true;

    # --- System Defaults ---
    system.defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        mru-spaces = false;
        orientation = "bottom";
      };

      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        FXPreferredViewStyle = "clmv"; 
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark"; 
        KeyRepeat = 2; 
        InitialKeyRepeat = 15;
      };
    };
  };
}

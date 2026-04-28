{
  config,
  lib,
  pkgs,
  isDarwin,
  ...
}:

{
  options.myFeatures.darwin.system.core = {
    enable = lib.mkEnableOption "Core macOS System Settings";
  };

  config = lib.mkIf (config.myFeatures.darwin.system.core.enable && pkgs.stdenv.isDarwin) {
    # 1. macOS Specific Performance & Behavior
    system.defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark"; # Dark mode
        "com.apple.mouse.tapBehavior" = 1; # Enable tap to click
      };
      dock = {
        autohide = true;
        show-recents = false; # Clean dock
      };
      finder = {
        _FXShowPosixPathInTitle = true; # Show full path in finder
        AppleShowAllExtensions = true;
      };
    };

    # 2. Keyboard & Input
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    # 3. macOS Environment Packages
    environment.systemPackages = with pkgs; [
      iterm2
      raycast
    ];
  };
}

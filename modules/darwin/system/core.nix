# modules/darwin/system/core.nix
# ============================================================================
# Core macOS System Defaults, Dock, Finder & Keyboard Preferences
# ============================================================================
# Configures native macOS `NSGlobalDomain`, Dock, Finder, and keyboard
# remapping (`CapsLock -> Control`), plus core macOS launcher utilities.
# Located under `modules/darwin/`, so `modules/default.nix` only imports this
# file when evaluating `darwinConfigurations`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.darwin.system.core;
in
{
  options.myFeatures.darwin.system.core = {
    enable = lib.mkEnableOption "Core macOS System Settings";
  };

  config = lib.mkIf cfg.enable {
    # 1. macOS UI, Dock & Finder Preferences
    system.defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark"; # System-wide Dark Mode
        "com.apple.mouse.tapBehavior" = 1; # Enable trackpad tap-to-click
      };
      dock = {
        autohide = true;
        show-recents = false;
      };
      finder = {
        _FXShowPosixPathInTitle = true; # Show full POSIX path in Finder window titles
        AppleShowAllExtensions = true;
      };
    };

    # 2. Keyboard & Modifier Remapping
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };

    # 3. macOS Productivity Applications
    environment.systemPackages = with pkgs; [
      iterm2
      raycast
    ];
  };
}

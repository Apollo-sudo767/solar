# modules/platforms/addons/displayManager.nix
# ============================================================================
# Display Manager Router & Output Synchronization Options
# ============================================================================
# Defines the shared `myFeatures.platforms.addons.displayManager` options.
# Individual greeter implementations live under `displayManager/<name>.nix`
# and activate when `manager` matches their name.
{
  lib,
  ...
}:

{
  options.myFeatures.platforms.addons.displayManager = {
    manager = lib.mkOption {
      type = lib.types.enum [
        "tuigreet"
        "gdm"
        "sddm"
        "regreet"
        "cosmic-greeter"
        "noctalia-greeter"
        "none"
      ];
      default = "none";
      description = "Login display manager / greeter to enable.";
    };
    primaryOutput = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Explicit primary monitor output for the display manager (e.g. 'DP-1'). If null, falls back to the desktop's primary monitor.";
    };
    syncOutputs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to synchronize monitor resolutions, positions, rotations, and primary focus from the desktop compositor configuration into the display manager.";
    };
    extraConfig = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra compositor configuration lines for Wayland-based display managers (e.g. Sway for ReGreet).";
    };
  };
}

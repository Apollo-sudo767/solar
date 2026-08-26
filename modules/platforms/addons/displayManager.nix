{
  config,
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
        "gtkGreet"
        "regreet"
        "cosmic-greeter"
        "none"
      ];
      default = "none";
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

  # The branch module itself doesn't need a mkIf cfg.enable because
  # it's just a router. Each leaf module has lib.mkIf (cfg.manager == "...")
}

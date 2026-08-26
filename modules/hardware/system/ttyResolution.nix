# This module allows setting the TTY resolution, which is particularly useful
# for fixing "stretched" or incorrect resolutions on boot and in TUI-based
# display managers like tuigreet.
{ config, lib, ... }:

let
  cfg = config.myFeatures.hardware.system.ttyResolution;
in
{
  options.myFeatures.hardware.system.ttyResolution = {
    enable = lib.mkEnableOption "TTY Resolution configuration";
    resolution = lib.mkOption {
      type = lib.types.str;
      default =
        if config.myFeatures.core.boot.resolution != null then
          config.myFeatures.core.boot.resolution
        else
          "2560x1440";
      description = "The resolution to set for the TTY (e.g., 2560x1440)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Bare resolution string (e.g. video=2560x1440) causes DRM driver mode rejection on Nvidia/SimpleDRM.
    # Omit bare video kernelParam to ensure clean DRM mode initialization.
  };
}

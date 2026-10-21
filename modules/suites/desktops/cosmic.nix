# modules/suites/desktops/cosmic.nix
# ============================================================================
# COSMIC Desktop Suite
# ============================================================================
# Composite desktop suite for System76's COSMIC desktop environment. Enables
# the COSMIC compositor/session, defaults the display manager to
# `cosmic-greeter`, and enables PipeWire audio and CUPS printing.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.desktops.cosmic;
in
{
  options.myFeatures.suites.desktops.cosmic = {
    enable = lib.mkEnableOption "COSMIC Desktop Suite";

    audio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable PipeWire low-latency audio.";
      };
    };

    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable CUPS printing daemon.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      platforms = {
        desktops.cosmic.enable = true;
        addons.displayManager.manager = lib.mkDefault "cosmic-greeter";
      };

      services = {
        multimedia.audio.enable = lib.mkIf cfg.audio.enable (lib.mkDefault true);
        hardware.printing.enable = lib.mkIf cfg.printing.enable (lib.mkDefault true);
      };
    };
  };
}

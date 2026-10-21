# modules/hardware/input/wooting.nix
# ============================================================================
# Wooting Analog Hall-Effect Keyboard Support
# ============================================================================
# Installs Wooting udev rules (`hardware.wooting.enable`) and the `wootility`
# configuration application for customizing actuation points and Rapid Trigger.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.hardware.input.wooting;
in
{
  options.myFeatures.hardware.input.wooting.enable = lib.mkEnableOption "Wooting Keyboard Support";

  config = lib.mkIf cfg.enable {
    hardware.wooting.enable = true;

    environment.systemPackages = [
      pkgs.wootility
      pkgs.wooting-udev-rules
    ];
  };
}

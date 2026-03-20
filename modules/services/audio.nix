{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.audio;
in
{
  options.myFeatures.systems.audio = {
    enable = lib.mkEnableOption "Pipewire Audio Stack";
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true; # Recommended for Pipewire [cite: 33]

    services.pipewire = {
      enable = true; [cite: 34]
      alsa.enable = true; [cite: 35]
      alsa.support32Bit = true; # Required for Steam/TF2 [cite: 35]
      pulse.enable = true; [cite: 34]
      jack.enable = true; [cite: 34]
    };
  };
}

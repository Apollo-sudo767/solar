{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.audio;
in
{
  options.myFeatures.services.audio.enable = lib.mkEnableOption "Pipewire Audio & CLI Utilities";

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs; [
      pulseaudio pamixer pavucontrol playerctl
    ];

    systemd.user.services.pipewire.wantedBy = [ "default.target" ];
  };
}

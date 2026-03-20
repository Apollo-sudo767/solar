{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.services.audio;
in
{
  options.myFeatures.services.audio.enable = lib.mkEnableOption "Pipewire Audio & CLI Utilities";

  config = lib.mkIf cfg.enable {
    # 1. Enable the Pipewire Service (The Engine)
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true; # Critical for Steam/Gaming parity
      pulse.enable = true;
      jack.enable = true;
    };

    # 2. Audio CLI Tools (Phanes Parity)
    environment.systemPackages = with pkgs; [
      pulseaudio # Provides 'pactl' for advanced routing
      pamixer    # Your primary CLI volume tool (used in Waybar)
      pavucontrol # Graphical mixer
      playerctl  # Media keys (Play/Pause/Next)
    ];

    # 3. User Persistence (Optional)
    # Ensures your volume levels stay consistent across reboots at Mizzou
    systemd.user.services.pipewire.wantedBy = [ "default.target" ];
  };
}

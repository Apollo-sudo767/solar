{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  inherit isDarwin isTotal;
  cfg = config.myFeatures.services.multimedia.audio;
in
{
  options.myFeatures.services.multimedia.audio.enable =
    lib.mkEnableOption "Pipewire Audio & CLI Utilities";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = with pkgs; [
          pulseaudio
          pamixer
          pavucontrol
          playerctl
        ];
      }

      (lib.optionalAttrs (!isDarwin) {
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;
        };

        systemd.user.services.pipewire.wantedBy = [ "default.target" ];
      })
    ]
  );
}

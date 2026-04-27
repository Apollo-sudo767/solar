{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.media.obs;
in
{
  options.myFeatures.programs.media.obs.enable = lib.mkEnableOption "OBS Studio";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      programs.obs-studio = {
        enable = true;
        # Only load Wayland/VAAPI plugins if on Linux
        plugins =
          if pkgs.stdenv.isLinux then
            (with pkgs.obs-studio-plugins; [
              wlrobs
              obs-vaapi
              obs-pipewire-audio-capture
            ])
          else
            [ ];
      };
    });
  };
}

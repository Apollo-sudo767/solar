# modules/programs/media/obs.nix
#
# Configures OBS Studio via Home Manager with Linux Wayland/VAAPI/PipeWire
# capture plugins and state preservation across Linux and macOS (`isTotal`).
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
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.obs-studio = {
        enable = true;
        # Only load Wayland/VAAPI plugins if on Linux
        plugins =
          if pkgs.stdenv.hostPlatform.isLinux then
            (with pkgs.obs-studio-plugins; [
              wlrobs
              obs-vaapi
              obs-pipewire-audio-capture
            ])
          else
            [ ];
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && pkgs.stdenv.hostPlatform.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/obs-studio"
            ];
          });
        };
  };
}

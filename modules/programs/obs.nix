{ config, lib, pkgs, ... }:
{
  options.myFeatures.programs.media.obs.enable = lib.mkEnableOption "OBS Studio with Wayland plugins";
  
  config = lib.mkIf config.myFeatures.programs.media.obs.enable {
    home-manager.users.apollo.programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs                 # Essential for Wayland/Niri capture
        obs-vaapi              # Hardware acceleration for your 4070 Ti
        obs-pipewire-audio-capture
      ];
    };
  };
}

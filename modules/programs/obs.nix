{ config, lib, pkgs, ... }:
let
  # Point this to the 'obs' attribute set, not the 'enable' boolean
  cfg = config.myFeatures.programs.obs;
in
{
  # Define the option as 'obs', which creates 'obs.enable' automatically
  options.myFeatures.programs.obs.enable = lib.mkEnableOption "OBS Studio with Wayland plugins";
  
  config = lib.mkIf cfg.enable {
    home-manager.users.apollo.programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs                 
        obs-vaapi              
        obs-pipewire-audio-capture
      ];
    };
  };
}

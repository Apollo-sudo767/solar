{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.systems.niri;
in
{
  
  options.myFeatures.systems.niri = {
    enable = lib.mkEnableOption "Niri Window Manager";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true; 

    environment.systemPackages = with pkgs; [
      fuzzel
      xwayland-satellite
      mako
      swaybg
      swayidle
      swaylock
      networkmanagerapplet
      thunar
      swww
      swaynotificationcenter
      brightnessctl
    ];
  };
}

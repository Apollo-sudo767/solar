{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.systems.niri;
in
{
  imports = [
    inputs.niri.homeManagerModules.niri
  ];
  
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
      hypridle
      swaylock
      networkmanagerapplet
      thunar
      swww
      swaynotificationcenter
    ];
  };
}

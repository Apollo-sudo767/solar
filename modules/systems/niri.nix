{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.systems.niri;
  # Reference the system platform correctly to avoid warnings
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.myFeatures.systems.niri = {
    enable = lib.mkEnableOption "Niri Window Manager";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri;

    environment.systemPackages = with pkgs; [
      fuzzel
      xwayland-satellite
      mako
      swaybg
      swayidle
      swaylock
      networkmanagerapplet
      thunar
      awww
      swaynotificationcenter
      brightnessctl
    ];
  };
}

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: # <-- Add pkgs.stdenv.isDarwin

let
  cfg = config.myFeatures.systems.niri;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.myFeatures.systems.niri.enable = lib.mkEnableOption "Niri Window Manager";

  # Shield everything
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

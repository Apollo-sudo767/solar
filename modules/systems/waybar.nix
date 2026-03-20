{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.systems.waybar;
in
{
  options.myFeatures.systems.waybar = {
    enable = lib.mkEnableOption "Waybar Status Bar";
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true; 
      package = pkgs.waybar.overrideAttrs (old: {
        mesonFlags = (old.mesonFlags or [ ]) ++ [
          "-Dexperimental=true"
          "-Dmpd=enabled"
          "-Dpulseaudio=enabled"
          "-Dmpris=enabled"
        ];
      });
    };
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.media.gaming;
in
{
  options.myFeatures.programs.media.gaming.enable = lib.mkEnableOption "Gaming Suite";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # Standard packages for both
      environment.systemPackages = with pkgs; [ prismlauncher ];
    }

    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
      };
      environment.systemPackages = with pkgs; [ mangohud gamemode libkrb5 keyutils ];
    }
  ]);
}

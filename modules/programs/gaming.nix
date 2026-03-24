{ config, lib, pkgs, ...  }:
let
  cfg = config.myFeatures.programs.gaming;
in
{
  options.myFeatures.programs.gaming = {
    enable = lib.mkEnableOption "Enables Steam and Prism Launcher";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
    
    environment.systemPackages = with pkgs; [
      prismlauncher
      mangohud
      gamemode
      libkrb5
      keyutils
    ];
  };
}

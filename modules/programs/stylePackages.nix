{ config, lib, pkgs, ...  }:

let
  cfg = config.myFeatures.programs.stylePackages;
in
{
  options.myFeatures.programs.stylePackages = {
    enable = lib.mkEnableOption "Enables style packages for terminal";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cbonsai
      cmatrix
      pipes
      asciiquarium
      cava
      vitetris
    ];
  };
}

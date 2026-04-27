{ config, lib, pkgs, ...  }:

let
  cfg = config.myFeatures.programs.utilities.stylePackages;
in
{
  options.myFeatures.programs.utilities.stylePackages = {
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

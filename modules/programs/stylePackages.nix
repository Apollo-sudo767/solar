{ config, lib, pkgs, ...  }:

let
  cfg = config.myFeatures.program.stylePackages;
in
{
  options.myFeatures.program.stylePackages = {
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

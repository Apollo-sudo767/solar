{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.lego;
in
{
  options.myFeatures.programs.utilities.lego.enable = lib.mkEnableOption "lego";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.lego ];
  };
}

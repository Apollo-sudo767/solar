{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.utilities.silverbullet;
in
{
  options.myFeatures.programs.utilities.silverbullet.enable =
    lib.mkEnableOption "SilverBullet Client";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.silverbullet ];
  };
}

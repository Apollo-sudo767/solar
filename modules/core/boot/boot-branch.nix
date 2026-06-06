{
  lib,
  config,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  options.myFeatures.core.boot.enable = lib.mkEnableOption "Bootloader Selection Branch";

  config = lib.mkIf cfg.enable {
    myFeatures.core.boot.boot.enable = lib.mkDefault true;
    myFeatures.core.boot.loader = lib.mkDefault "limine";
  };
}

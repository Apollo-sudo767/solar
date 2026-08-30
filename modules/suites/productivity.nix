{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.suites.productivity;
in
{
  options.myFeatures.suites.productivity = {
    enable = lib.mkEnableOption "Productivity & Office Suite (AP-Office)";
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      programs.office.ap-office.enable = lib.mkDefault true;
      services.hardware.printing.enable = lib.mkDefault true;
    };
  };
}

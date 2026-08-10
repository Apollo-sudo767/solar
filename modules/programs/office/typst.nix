{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.typst;
in
{
  options.myFeatures.programs.office.typst = {
    enable = lib.mkEnableOption "Typst modern typesetting engine & PDF compiler";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.typst ];
  };
}

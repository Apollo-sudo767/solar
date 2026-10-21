# modules/programs/office/typst.nix
#
# Installs the Typst typesetting engine and PDF compiler across Linux and macOS (`isTotal`).
{
  config,
  lib,
  pkgs,
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

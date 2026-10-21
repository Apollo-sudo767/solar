# modules/programs/office/pandoc.nix
#
# Installs the Pandoc document converter and optional TeX Live distribution
# across Linux and macOS (`isTotal`).
{
  config,
  lib,
  pkgs,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.pandoc;
in
{
  options.myFeatures.programs.office.pandoc = {
    enable = lib.mkEnableOption "Pandoc & TeX Live document publishing engine";
    texlive = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to include TeX Live system package for PDF generation.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.pandoc ] ++ lib.optional cfg.texlive pkgs.texliveMedium;
  };
}

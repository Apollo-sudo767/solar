{
  config,
  lib,
  pkgs,
  isDarwin,
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

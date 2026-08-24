{
  config,
  lib,
  pkgs,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.lightweight;
in
{
  options.myFeatures.programs.office.lightweight = {
    enable = lib.mkEnableOption "Lightweight modular office tools (AbiWord, Gnumeric, PDFArranger, Evince)";

    abiword = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable AbiWord lightweight GTK word processor.";
    };
    gnumeric = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Gnumeric high-speed spreadsheet engine.";
    };
    pdfarranger = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable PDFArranger page merger & re-order utility.";
    };
    evince = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Evince document viewer for PDF and PostScript.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      lib.optional (cfg.abiword && !pkgs.stdenv.hostPlatform.isDarwin) pkgs.abiword
      ++ lib.optional (cfg.gnumeric && !pkgs.stdenv.hostPlatform.isDarwin) pkgs.gnumeric
      ++ lib.optional (cfg.pdfarranger && !pkgs.stdenv.hostPlatform.isDarwin) pkgs.pdfarranger
      ++ lib.optional (cfg.evince && !pkgs.stdenv.hostPlatform.isDarwin) pkgs.evince;
  };
}

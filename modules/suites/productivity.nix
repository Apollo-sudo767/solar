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
    enable = lib.mkEnableOption "Productivity & Office Suite (AP-Office / Lightweight Office, Printing)";

    mode = lib.mkOption {
      type = lib.types.enum [
        "full"
        "lightweight"
      ];
      default = "full";
      description = "Productivity suite profile: 'full' for AP-Office (heavy document suite) or 'lightweight' for modular tools.";
    };

    apOffice = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable complete AP-Office suite (LibreOffice, OnlyOffice, Zotero, Typst, Joplin, etc.) when mode is 'full'.";
      };
    };

    lightweight = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable lightweight modular office tools (AbiWord, Gnumeric, PDFArranger, Evince) when mode is 'lightweight'.";
      };
    };

    printing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable CUPS printing daemon subsystem.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures = {
      programs.office = {
        ap-office.enable = lib.mkIf (cfg.mode == "full" && cfg.apOffice.enable) (lib.mkDefault true);
        lightweight.enable = lib.mkIf (cfg.mode == "lightweight" && cfg.lightweight.enable) (
          lib.mkDefault true
        );
      };
      services.hardware.printing.enable = lib.mkIf cfg.printing.enable (lib.mkDefault true);
    };
  };
}

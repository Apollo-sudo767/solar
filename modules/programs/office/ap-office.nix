{
  config,
  lib,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.ap-office;
in
{
  options.myFeatures.programs.office.ap-office = {
    enable = lib.mkEnableOption "AP Office Suite (Joplin, Zotero, Pandoc, LibreOffice, Trilium)";

    joplin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Joplin notes application in AP Office Suite.";
    };
    zotero = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Zotero reference manager in AP Office Suite.";
    };
    pandoc = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Pandoc & TeX Live publishing engine in AP Office Suite.";
    };
    libreoffice = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include LibreOffice suite in AP Office Suite.";
    };
    trilium = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Trilium Notes in AP Office Suite.";
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.programs.office.joplin.enable = lib.mkDefault cfg.joplin;
    myFeatures.programs.office.zotero.enable = lib.mkDefault cfg.zotero;
    myFeatures.programs.office.pandoc.enable = lib.mkDefault cfg.pandoc;
    myFeatures.programs.office.libreoffice.enable = lib.mkDefault cfg.libreoffice;
    myFeatures.programs.office.trilium.enable = lib.mkDefault cfg.trilium;
  };
}

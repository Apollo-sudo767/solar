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
    enable = lib.mkEnableOption "AP Office Academic Suite (Joplin, Zotero, Pandoc, Typst, LanguageTool)";

    joplin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Joplin core writing workspace & Markdown engine in AP Office Suite.";
    };
    zotero = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Zotero reference manager & PDF manager in AP Office Suite.";
    };
    defaultPdf = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Zotero as the default PDF reader when AP Office is enabled.";
    };
    pandoc = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Pandoc universal document converter in AP Office Suite.";
    };
    typst = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Typst modern typesetting engine & PDF compiler in AP Office Suite.";
    };
    languagetool = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include LanguageTool desktop proofreading & style linter in AP Office Suite.";
    };
  };

  config = lib.mkIf cfg.enable {
    myFeatures.programs.office.joplin.enable = lib.mkDefault cfg.joplin;
    myFeatures.programs.office.zotero.enable = lib.mkDefault cfg.zotero;
    myFeatures.programs.office.zotero.defaultPdf = lib.mkDefault cfg.defaultPdf;
    myFeatures.programs.office.pandoc.enable = lib.mkDefault cfg.pandoc;
    myFeatures.programs.office.typst.enable = lib.mkDefault cfg.typst;
    myFeatures.programs.office.languagetool.enable = lib.mkDefault cfg.languagetool;
  };
}

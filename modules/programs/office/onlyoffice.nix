{
  config,
  lib,
  pkgs,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.onlyoffice;
in
{
  options.myFeatures.programs.office.onlyoffice = {
    enable = lib.mkEnableOption "ONLYOFFICE Desktop Editors";

    defaultFormat = lib.mkOption {
      type = lib.types.enum [
        "ooxml"
        "odf"
      ];
      default = "ooxml";
      description = "Default document format target (.docx/.xlsx/.pptx vs .odt/.ods/.odp).";
    };

    enablePlugins = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ONLYOFFICE plugins store (Translator, OCR, HTML, YouTube).";
    };

    enableSpellcheck = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ONLYOFFICE spellchecking engine.";
    };

    uiTheme = lib.mkOption {
      type = lib.types.enum [
        "dark"
        "light"
        "system"
        "classic"
      ];
      default = "dark";
      description = "ONLYOFFICE UI theme preset.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional (!pkgs.stdenv.isDarwin) pkgs.onlyoffice-bin;

    homebrew.casks =
      lib.optionals (pkgs.stdenv.isDarwin && config.myFeatures.darwin.system.homebrew.enable or false)
        [
          "onlyoffice"
        ];

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xdg.mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
        enable = true;
        defaultApplications = {
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [
            "onlyoffice-desktopeditors.desktop"
          ];
          "application/msword" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [
            "onlyoffice-desktopeditors.desktop"
          ];
          "application/vnd.ms-excel" = [ "onlyoffice-desktopeditors.desktop" ];
          "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [
            "onlyoffice-desktopeditors.desktop"
          ];
          "application/vnd.ms-powerpoint" = [ "onlyoffice-desktopeditors.desktop" ];
        };
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/onlyoffice"
            ];
          });
        };
  };
}

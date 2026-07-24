{
  config,
  lib,
  pkgs,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.calligra;
in
{
  options.myFeatures.programs.office.calligra = {
    enable = lib.mkEnableOption "KDE Calligra Suite";

    components = {
      words = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Calligra Words text processing application.";
      };
      sheets = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Calligra Sheets spreadsheet application.";
      };
      stage = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Calligra Stage presentation manager.";
      };
      plan = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Calligra Plan project management tool.";
      };
      karbon = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Calligra Karbon vector graphics editor.";
      };
    };

    enableKrita = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Krita raster graphics painter alongside Calligra.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [
        kdePackages.calligra
      ]
      ++ lib.optional cfg.enableKrita pkgs.krita;

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xdg.mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
        enable = true;
        defaultApplications = {
          "application/vnd.oasis.opendocument.text" = lib.mkIf cfg.components.words [
            "org.kde.calligrawords.desktop"
          ];
          "application/vnd.oasis.opendocument.spreadsheet" = lib.mkIf cfg.components.sheets [
            "org.kde.calligrasheets.desktop"
          ];
          "application/vnd.oasis.opendocument.presentation" = lib.mkIf cfg.components.stage [
            "org.kde.calligrastage.desktop"
          ];
        };
      };
    });

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/calligra"
            ];
          });
        };
  };
}

{
  config,
  lib,
  pkgs,
  isDarwin ? false,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.wpsoffice;
in
{
  options.myFeatures.programs.office.wpsoffice = {
    enable = lib.mkEnableOption "WPS Office Suite";

    components = {
      writer = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "WPS Writer word processor.";
      };
      spreadsheets = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "WPS Spreadsheets spreadsheet app.";
      };
      presentation = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "WPS Presentation slide deck editor.";
      };
      pdf = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "WPS PDF viewer and editor.";
      };
    };

    enableSymbolFonts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install missing WPS Office symbol fonts (Wingdings, Webdings, Symbol).";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages =
          lib.optional (!isDarwin) pkgs.wpsoffice
          ++ lib.optional (cfg.enableSymbolFonts && !isDarwin) pkgs.wps-office-fonts;

        home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          xdg.mimeApps = lib.mkIf (!isDarwin) {
            enable = true;
            defaultApplications = {
              "application/msword" = lib.mkIf cfg.components.writer [ "wps-office-prometheus.desktop" ];
              "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
                lib.mkIf cfg.components.writer
                  [ "wps-office-prometheus.desktop" ];
              "application/vnd.ms-excel" = lib.mkIf cfg.components.spreadsheets [ "wps-office-et.desktop" ];
              "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" =
                lib.mkIf cfg.components.spreadsheets
                  [ "wps-office-et.desktop" ];
              "application/vnd.ms-powerpoint" = lib.mkIf cfg.components.presentation [ "wps-office-wpp.desktop" ];
              "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
                lib.mkIf cfg.components.presentation
                  [ "wps-office-wpp.desktop" ];
              "application/pdf" = lib.mkIf cfg.components.pdf [ "wps-office-pdf.desktop" ];
            };
          };
        });

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf (config.myFeatures.core.system.preservation.enable or false && !isDarwin)
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
                  ".config/Kingsoft"
                ];
              });
            };
      }
      (lib.optionalAttrs isDarwin {
        homebrew.casks = lib.optionals (config.myFeatures.darwin.system.homebrew.enable or false) [
          "wps-office"
        ];
      })
    ]
  );
}

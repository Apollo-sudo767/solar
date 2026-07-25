{
  config,
  lib,
  pkgs,
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

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      lib.optional (!pkgs.stdenv.isDarwin) pkgs.wpsoffice
      ++ lib.optional (cfg.enableSymbolFonts && !pkgs.stdenv.isDarwin) pkgs.wps-office-fonts;

    homebrew.casks =
      lib.optionals (pkgs.stdenv.isDarwin && config.myFeatures.darwin.system.homebrew.enable or false)
        [
          "wps-office"
        ];

    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      xdg.mimeApps = lib.mkIf (!pkgs.stdenv.isDarwin) {
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
      lib.mkIf (config.myFeatures.core.system.preservation.enable or false && pkgs.stdenv.isLinux)
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/Kingsoft"
            ];
          });
        };
  };
}

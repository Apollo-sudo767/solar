# modules/programs/office/onlyoffice.nix
# ============================================================================
# ONLYOFFICE Desktop Editors
# ============================================================================
# Installs ONLYOFFICE Desktop Editors (`pkgs.onlyoffice-bin` on Linux, Homebrew
# Cask on macOS) and configures default MIME handlers for Office Open XML
# (`.docx`/`.xlsx`/`.pptx`) and optionally OpenDocument (`.odt`/`.ods`/`.odp`).
{
  config,
  lib,
  pkgs,
  isDarwin ? false,
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
      description = "Default document format target ('ooxml' for .docx/.xlsx/.pptx, 'odf' to also claim .odt/.ods/.odp).";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = lib.optional (!isDarwin) pkgs.onlyoffice-bin;

        home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          xdg.mimeApps = lib.mkIf (!isDarwin) {
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
            }
            // lib.optionalAttrs (cfg.defaultFormat == "odf") {
              "application/vnd.oasis.opendocument.text" = [ "onlyoffice-desktopeditors.desktop" ];
              "application/vnd.oasis.opendocument.spreadsheet" = [ "onlyoffice-desktopeditors.desktop" ];
              "application/vnd.oasis.opendocument.presentation" = [ "onlyoffice-desktopeditors.desktop" ];
            };
          };
        });

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf (config.myFeatures.core.system.preservation.enable or false && !isDarwin)
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
                  ".config/onlyoffice"
                ];
              });
            };
      }
      (lib.optionalAttrs isDarwin {
        homebrew.casks = lib.optionals (config.myFeatures.darwin.system.homebrew.enable or false) [
          "onlyoffice"
        ];
      })
    ]
  );
}

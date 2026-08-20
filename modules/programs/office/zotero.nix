{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.zotero;

  # Derive Better BibTeX plugin (.xpi) for Zotero citekey generation
  betterBibtexXpi = pkgs.fetchurl {
    url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v7.0.24/zotero-better-bibtex-7.0.24.xpi";
    hash = "sha256-A9amheuaMQvoYd3kzVxm8LwWHwNcT76ClKXSXPwbCcY=";
  };

  # Derive Zutilo plugin (.xpi) for Zotero quick URI & shortcut utilities
  zutiloXpi = pkgs.fetchurl {
    url = "https://github.com/wshanks/Zutilo/releases/download/v3.10.0/zutilo.xpi";
    hash = "sha256-cT8ibaJ29rJxxPpaDQ/yUZeZx8hbtV7xK+rMZ+UGb+Q=";
  };
in
{
  options.myFeatures.programs.office.zotero = {
    enable = lib.mkEnableOption "Zotero desktop reference manager & PDF assistant";
    gui = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install the Zotero GUI client application.";
    };
    betterBibtex = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Better BibTeX plugin support for static citekey generation (@smith2024).";
    };
    zutilo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Zutilo plugin for Zotero quick URI copying & shortcuts.";
    };
    connector = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable browser Zotero Connector extension for one-click web source & DOI capture.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        environment.systemPackages = lib.optional cfg.gui pkgs.zotero;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
                  ".zotero"
                  "Zotero"
                ];
              });
            };
      })
      (lib.optionalAttrs isDarwin {
        homebrew.casks = lib.optional cfg.gui "zotero";
      })
      {
        home-manager.sharedModules = [
          {
            home.file = lib.mkMerge [
              (lib.mkIf (cfg.gui && cfg.betterBibtex) {
                ".local/share/zotero/plugins/better-bibtex@iris-advies.com.xpi".source = betterBibtexXpi;
              })
              (lib.mkIf (cfg.gui && cfg.zutilo) {
                ".local/share/zotero/plugins/zutilo@www.wesailatdawn.com.xpi".source = zutiloXpi;
              })
              (lib.mkIf (isDarwin && cfg.gui && cfg.betterBibtex) {
                "Library/Application Support/Zotero/plugins/better-bibtex@iris-advies.com.xpi".source =
                  betterBibtexXpi;
              })
              (lib.mkIf (isDarwin && cfg.gui && cfg.zutilo) {
                "Library/Application Support/Zotero/plugins/zutilo@www.wesailatdawn.com.xpi".source = zutiloXpi;
              })
            ];
          }
        ];
      }
    ]
  );
}

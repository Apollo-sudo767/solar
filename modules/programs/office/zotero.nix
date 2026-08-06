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
    hash = "sha256-5B1a4Y8x2w34h/R0Q3pZ7Y033z6gV4r6W2R5W6L8K90=";
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
    ]
  );
}

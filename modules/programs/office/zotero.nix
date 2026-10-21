# modules/programs/office/zotero.nix
#
# Configures the Zotero reference manager, Better BibTeX extension provisioning,
# and optional default PDF reader associations across Linux and macOS.
{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isStable ? false,
  ...
}:

let
  cfg = config.myFeatures.programs.office.zotero;

  # Upstream nixpkgs-unstable's zotero currently fails to build due to an incompatible
  # regex in its build script against firefox-esr-153. Fall back to nixpkgs-stable's pre-built binary.
  zotero =
    if (!isStable && inputs ? nixpkgs-stable) then
      (inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zotero or pkgs.zotero)
    else
      pkgs.zotero;

  # Derive Better BibTeX plugin (.xpi) for Zotero citekey generation & auto-export
  betterBibtexXpi = pkgs.fetchurl {
    url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v9.0.63/zotero-better-bibtex-9.0.63.xpi";
    hash = "sha256-Ok0IDslBU6jCS/gnVonF+UbZnjFLauD6tQYNaXD1Y4g=";
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
    defaultPdf = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Zotero as the default application for opening PDF files.";
    };
    betterBibtex = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Better BibTeX plugin support for static citekey generation and auto-export.";
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
        environment.systemPackages = lib.optional cfg.gui zotero;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories = [
                  ".zotero"
                  "Zotero"
                  ".config/zotero"
                ];
              });
            };
      })
      (lib.optionalAttrs isDarwin {
        homebrew.casks = lib.optional cfg.gui "zotero";
      })
      {
        home-manager.sharedModules = [
          ({ config, ... }: {
            home.file = lib.mkMerge [
              (lib.mkIf (cfg.gui && cfg.betterBibtex) {
                "Downloads/zotero-better-bibtex.xpi".source = betterBibtexXpi;
              })
            ];

            home.activation.linkZoteroPlugins = lib.mkIf (cfg.gui && cfg.betterBibtex) (
              config.lib.dag.entryAfter [ "writeBoundary" ] ''
                ${
                  if isDarwin then
                    ''
                      zpath="$HOME/Library/Application Support/Zotero/Profiles"
                    ''
                  else
                    ''
                      zpath="$HOME/.zotero/zotero"
                    ''
                }
                if [ -d "$zpath" ]; then
                  for profile in "$zpath"/*/; do
                    if [ -d "$profile" ]; then
                      mkdir -p "$profile/extensions"
                      if [ -L "$profile/extensions/better-bibtex@iris-advies.com.xpi" ]; then
                        rm -f "$profile/extensions/better-bibtex@iris-advies.com.xpi"
                      fi
                      cp -f "${betterBibtexXpi}" "$profile/extensions/better-bibtex@iris-advies.com.xpi"
                      chmod 644 "$profile/extensions/better-bibtex@iris-advies.com.xpi"
                      touch "$profile/user.js"
                      if ! grep -q "extensions.autoDisableScopes" "$profile/user.js"; then
                        printf '\nuser_pref("extensions.autoDisableScopes", 0);\nuser_pref("extensions.enabledScopes", 15);\nuser_pref("xpinstall.signatures.required", false);\nuser_pref("extensions.experiments.enabled", true);\n' >> "$profile/user.js"
                      fi
                    fi
                  done
                fi
              ''
            );

            xdg.mimeApps = lib.mkIf (!isDarwin && cfg.gui && cfg.defaultPdf) {
              enable = true;
              defaultApplications = {
                "application/pdf" = [ "zotero.desktop" ];
                "application/x-pdf" = [ "zotero.desktop" ];
              };
            };
          })
        ];
      }
    ]
  );
}

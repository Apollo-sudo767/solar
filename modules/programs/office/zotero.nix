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

  # Derive Better BibTeX plugin (.xpi) for Zotero citekey generation & auto-export
  betterBibtexXpi = pkgs.fetchurl {
    url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v9.0.63/zotero-better-bibtex-9.0.63.xpi";
    hash = "sha256-Ok0IDslBU6jCS/gnVonF+UbZnjFLauD6tQYNaXD1Y4g=";
  };
  # Custom Zotero package bundled with Better BibTeX distribution extension and auto-profile linking
  zoteroPkg = pkgs.runCommand "zotero-with-plugins-${pkgs.zotero.version}" { } ''
    mkdir -p $out/lib $out/share $out/bin
    cp -r ${pkgs.zotero}/share/* $out/share/
    chmod -R +w $out/share
    sed -i 's|^MimeType=.*|MimeType=x-scheme-handler/zotero;text/plain;application/pdf;application/x-pdf;|' $out/share/applications/zotero.desktop 2>/dev/null || true

    for item in ${pkgs.zotero}/lib/*; do
      base=$(basename "$item")
      if [ "$base" != "distribution" ] && [ "$base" != "zotero" ]; then
        ln -s "$item" "$out/lib/$base"
      fi
    done
    mkdir -p $out/lib/distribution/extensions
    cp -r ${pkgs.zotero}/lib/distribution/* $out/lib/distribution/ 2>/dev/null || true
    ${lib.optionalString cfg.betterBibtex ''
      cp -f ${betterBibtexXpi} $out/lib/distribution/extensions/better-bibtex@iris-advies.com.xpi
      chmod 644 $out/lib/distribution/extensions/better-bibtex@iris-advies.com.xpi
    ''}

    cat << EOF > $out/lib/zotero
    #!${pkgs.runtimeShell}
    ulimit -n 4096
    export MOZ_ALLOW_DOWNGRADE=1
    export MOZ_LEGACY_PROFILES=1
    export MOZ_ENABLE_WAYLAND=1

    ${lib.optionalString cfg.betterBibtex ''
      # Auto-link Better BibTeX and auto-enable extensions without manual approval prompts
      if [ -d "\$HOME/.zotero/zotero" ]; then
        for profile in "\$HOME/.zotero/zotero"/*/; do
          if [ -d "\$profile" ]; then
            mkdir -p "\$profile/extensions"
            if [ -L "\$profile/extensions/better-bibtex@iris-advies.com.xpi" ]; then
              rm -f "\$profile/extensions/better-bibtex@iris-advies.com.xpi"
            fi
            cp -f "${betterBibtexXpi}" "\$profile/extensions/better-bibtex@iris-advies.com.xpi"
            chmod 644 "\$profile/extensions/better-bibtex@iris-advies.com.xpi"
            touch "\$profile/user.js"
            if ! grep -q "extensions.autoDisableScopes" "\$profile/user.js"; then
              printf '\nuser_pref("extensions.autoDisableScopes", 0);\nuser_pref("extensions.enabledScopes", 15);\nuser_pref("xpinstall.signatures.required", false);\nuser_pref("extensions.experiments.enabled", true);\n' >> "\$profile/user.js"
            fi
          fi
        done
      fi
    ''}

    CALLDIR="\$(dirname "\$(readlink -f "\$0")")"
    "\$CALLDIR/zotero-bin" -app "\$CALLDIR/app/application.ini" "\$@"
    EOF
    chmod +x $out/lib/zotero

    ln -s $out/lib/zotero $out/bin/.zotero-wrapped
    cp ${pkgs.zotero}/bin/zotero $out/bin/zotero
    chmod +w $out/bin/zotero
    sed -i "s|${pkgs.zotero}|$out|g" $out/bin/zotero
  '';
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
        environment.systemPackages = lib.optional cfg.gui zoteroPkg;

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

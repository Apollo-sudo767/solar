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
    url = "https://github.com/retorquere/zotero-better-bibtex/releases/download/v9.0.58/zotero-better-bibtex-9.0.58.xpi";
    hash = "sha256-/Dp8SnIi5zwMjjEHD5VXG+rEywn+cDaA3UX0NsQweeA=";
  };
  # Custom Zotero package bundled with Better BibTeX distribution extension
  zoteroPkg =
    if (!cfg.betterBibtex) then
      pkgs.zotero
    else
      pkgs.symlinkJoin {
        name = "zotero-with-plugins-${pkgs.zotero.version}";
        paths = [ pkgs.zotero ];
        postBuild = ''
          rm -rf $out/lib/distribution $out/bin/zotero $out/bin/.zotero-wrapped
          mkdir -p $out/lib/distribution/extensions $out/lib/app/distribution/extensions
          cp -r ${pkgs.zotero}/lib/distribution/* $out/lib/distribution/ 2>/dev/null || true
          ln -sf ${betterBibtexXpi} $out/lib/distribution/extensions/better-bibtex@iris-advies.com.xpi
          ln -sf ${betterBibtexXpi} $out/lib/app/distribution/extensions/better-bibtex@iris-advies.com.xpi
          ln -s $out/lib/zotero $out/bin/.zotero-wrapped
          cp ${pkgs.zotero}/bin/zotero $out/bin/zotero
          chmod +w $out/bin/zotero
          sed -i "s|${pkgs.zotero}|$out|g" $out/bin/zotero
        '';
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
                "Downloads/zotero-better-bibtex.xpi".source = betterBibtexXpi;
              })
              (lib.mkIf (isDarwin && cfg.gui && cfg.betterBibtex) {
                "Library/Application Support/Zotero/Profiles/sliytu6c.default/extensions/better-bibtex@iris-advies.com.xpi".source =
                  betterBibtexXpi;
              })
            ];
          }
        ];
      }
    ]
  );
}

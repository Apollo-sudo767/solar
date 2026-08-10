{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.programs.office.joplin;
  hasPlugins = cfg.gui && cfg.plugins.enable;

  # Derive Jopdoc Joplin Desktop plugin (.jpl) from official NPM package release
  jopdocJpl =
    pkgs.runCommand "jopdoc.nsharris247.jpl"
      {
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/joplin-plugin-jopdoc/-/joplin-plugin-jopdoc-1.0.3.tgz";
          hash = "sha256-rrdq8PBxuttrjAQ+RzlfQLBLWrENKltPPrcKCE1D8VI=";
        };
        nativeBuildInputs = [ pkgs.gnutar ];
      }
      ''
        tar -xzf $src package/publish/jopdoc.nsharris247.jpl
        mv package/publish/jopdoc.nsharris247.jpl $out
      '';

  # Derive Zotero Link Joplin Desktop plugin (.jpl) from official NPM package release
  zoteroLinkJpl =
    pkgs.runCommand "nz.magnusso.zotero-link.jpl"
      {
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/joplin-plugin-zotero-link/-/joplin-plugin-zotero-link-2.1.5.tgz";
          hash = "sha256-BbvF7BDoIwkiEITFKmy2A00JXX580se9wCx23cD+bYE=";
        };
        nativeBuildInputs = [ pkgs.gnutar ];
      }
      ''
        tar -xzf $src package/publish/nz.magnusso.zotero-link.jpl
        mv package/publish/nz.magnusso.zotero-link.jpl $out
      '';
in
{
  options.myFeatures.programs.office.joplin = {
    enable = lib.mkEnableOption "Joplin Desktop & CLI note-taking application";
    gui = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install the Joplin Desktop client application.";
    };
    cli = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the Joplin CLI client.";
    };
    plugins = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Joplin desktop plugins (Jopdoc, Zotero Link).";
      };
      jopdoc = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install Jopdoc export plugin for Joplin desktop.";
      };
      zoteroLink = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install Zotero Link plugin for Joplin desktop.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories =
                  (lib.optional cfg.gui ".config/joplin-desktop") ++ (lib.optional cfg.cli ".config/joplin");
              });
            };
      })
      {
        environment.systemPackages =
          (lib.optional cfg.gui pkgs.joplin-desktop) ++ (lib.optional cfg.cli pkgs.joplin-cli);

        home-manager.sharedModules = lib.mkIf hasPlugins [
          {
            home.file = lib.mkMerge [
              (lib.mkIf cfg.plugins.jopdoc {
                ".config/joplin-desktop/plugins/jopdoc.nsharris247.jpl".source = jopdocJpl;
              })
              (lib.mkIf cfg.plugins.zoteroLink {
                ".config/joplin-desktop/plugins/nz.magnusso.zotero-link.jpl".source = zoteroLinkJpl;
              })
              (lib.mkIf (isDarwin && cfg.plugins.jopdoc) {
                "Library/Application Support/joplin-desktop/plugins/jopdoc.nsharris247.jpl".source = jopdocJpl;
              })
              (lib.mkIf (isDarwin && cfg.plugins.zoteroLink) {
                "Library/Application Support/joplin-desktop/plugins/nz.magnusso.zotero-link.jpl".source =
                  zoteroLinkJpl;
              })
            ];
          }
        ];
      }
    ]
  );
}

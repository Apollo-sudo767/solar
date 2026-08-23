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

  # Derive BibTeX Joplin Desktop plugin (.jpl) from official NPM package release
  bibtexJpl =
    pkgs.runCommand "com.xUser5000.bibtex.jpl"
      {
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/joplin-plugin-bibtex/-/joplin-plugin-bibtex-0.5.0.tgz";
          hash = "sha256-zg9YrXPbiRCFcIFMLIVUMafvPucvmDMnsDO+69L9r8k=";
        };
        nativeBuildInputs = [ pkgs.gnutar ];
      }
      ''
        tar -xzf $src package/publish/com.xUser5000.bibtex.jpl
        mv package/publish/com.xUser5000.bibtex.jpl $out
      '';

  # Derive Outline / Heading Navigator Joplin Desktop plugin (.jpl) from official NPM package release
  outlineJpl =
    pkgs.runCommand "outline.jpl"
      {
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/joplin-plugin-outline/-/joplin-plugin-outline-1.5.15.tgz";
          hash = "sha256-KiHEDNGuw37cKXFbU1OuWnyasi8QI3ubhvLQMxRQu/Y=";
        };
        nativeBuildInputs = [ pkgs.gnutar ];
      }
      ''
        tar -xzf $src package/publish/outline.jpl
        mv package/publish/outline.jpl $out
      '';

  # Derive Rich Markdown Joplin Desktop plugin (.jpl) from official NPM package release
  richMarkdownJpl =
    pkgs.runCommand "plugin.calebjohn.rich-markdown.jpl"
      {
        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/joplin-plugin-rich-markdown/-/joplin-plugin-rich-markdown-0.17.1.tgz";
          hash = "sha256-dAMpsK5Sc0WshCOdwe4wuwKqtnJHwuyktJJNxm/5OW8=";
        };
        nativeBuildInputs = [ pkgs.gnutar ];
      }
      ''
        tar -xzf $src package/publish/plugin.calebjohn.rich-markdown.jpl
        mv package/publish/plugin.calebjohn.rich-markdown.jpl $out
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
        default = true;
        description = "Enable Joplin desktop plugins (Jopdoc, BibTeX, Outline, Rich Markdown).";
      };
      jopdoc = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install Jopdoc export plugin for Joplin desktop.";
      };
      bibtex = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install BibTeX plugin for Joplin desktop.";
      };
      outline = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install Outline / Heading Navigator plugin for Joplin desktop.";
      };
      richMarkdown = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install Rich Markdown plugin for Joplin desktop.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.optionalAttrs (!isDarwin) {
        environment.systemPackages =
          (lib.optional cfg.gui pkgs.joplin-desktop) ++ (lib.optional cfg.cli pkgs.joplin-cli);

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
                directories =
                  (lib.optional cfg.gui ".config/joplin-desktop") ++ (lib.optional cfg.cli ".config/joplin");
              });
            };
      })
      (lib.optionalAttrs isDarwin {
        homebrew.casks = lib.optional cfg.gui "joplin";
        environment.systemPackages = lib.optional cfg.cli pkgs.joplin-cli;
      })
      {
        home-manager.sharedModules = lib.mkIf hasPlugins [
          {
            home.file = lib.mkMerge [
              (lib.mkIf cfg.plugins.jopdoc {
                ".config/joplin-desktop/plugins/jopdoc.nsharris247.jpl".source = jopdocJpl;
              })
              (lib.mkIf cfg.plugins.bibtex {
                ".config/joplin-desktop/plugins/com.xUser5000.bibtex.jpl".source = bibtexJpl;
              })
              (lib.mkIf cfg.plugins.outline {
                ".config/joplin-desktop/plugins/outline.jpl".source = outlineJpl;
              })
              (lib.mkIf cfg.plugins.richMarkdown {
                ".config/joplin-desktop/plugins/plugin.calebjohn.rich-markdown.jpl".source = richMarkdownJpl;
              })
            ];
          }
        ];
      }
    ]
  );
}

{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal ? true,
  ...
}:

let
  cfg = config.myFeatures.services.servers.joplin;
  isServerType = cfg.type == "server" || cfg.type == "both" || cfg.type == "all";
  isDesktopType = cfg.type == "desktop" || cfg.type == "both" || cfg.type == "all";
  isCliType = cfg.cli || cfg.type == "cli" || cfg.type == "all";
  hasPlugins = isDesktopType && (cfg.extraTools || cfg.plugins.enable || cfg.researchTools);

  # Derive Jopdoc Joplin Desktop plugin (.jpl) from official NPM package release
  jopdocJpl = pkgs.runCommand "jopdoc.nsharris247.jpl" {
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/joplin-plugin-jopdoc/-/joplin-plugin-jopdoc-1.0.3.tgz";
      hash = "sha256-rrdq8PBxuttrjAQ+RzlfQLBLWrENKltPPrcKCE1D8VI=";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
  } ''
    tar -xzf $src package/publish/jopdoc.nsharris247.jpl
    mv package/publish/jopdoc.nsharris247.jpl $out
  '';

  # Derive Zotero Link Joplin Desktop plugin (.jpl) from official NPM package release
  zoteroLinkJpl = pkgs.runCommand "nz.magnusso.zotero-link.jpl" {
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/joplin-plugin-zotero-link/-/joplin-plugin-zotero-link-2.1.5.tgz";
      hash = "sha256-BbvF7BDoIwkiEITFKmy2A00JXX580se9wCx23cD+bYE=";
    };
    nativeBuildInputs = [ pkgs.gnutar ];
  } ''
    tar -xzf $src package/publish/nz.magnusso.zotero-link.jpl
    mv package/publish/nz.magnusso.zotero-link.jpl $out
  '';
in
{
  imports = lib.optional (!isDarwin) inputs.joplin-server.nixosModules.default;

  options.myFeatures.services.servers.joplin = {
    enable = lib.mkEnableOption "Joplin Synchronization Server, Desktop, & CLI (Solar Managed)";
    type = lib.mkOption {
      type = lib.types.enum [
        "server"
        "desktop"
        "both"
        "cli"
        "all"
      ];
      default = "both";
      description = "Whether to deploy the Joplin Server service, Joplin Desktop client, CLI, or all.";
    };
    cli = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install the Joplin CLI client.";
    };
    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://joplin.apollan.cc";
      description = "Public base URL of Joplin Server.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 22300;
      description = "Listening port for Joplin Server.";
    };
    extraTools = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install Pandoc, Zotero, and TeX Live system dependencies alongside Jopdoc and Zotero Link Joplin desktop plugins.";
    };
    researchTools = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Alias for extraTools: Enable research & document workflow plugins (Jopdoc, Zotero Link) and system tools.";
    };
    plugins = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Joplin desktop plugins (Jopdoc, Zotero Link) and system dependencies (Pandoc, Zotero, TeX Live).";
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
        services.joplin-server = lib.mkIf isServerType {
          enable = true;
          inherit (cfg) baseUrl port;
          database.createLocally = true;
          nginx.enable = true;
        };

        networking.firewall.allowedTCPPorts = lib.mkIf isServerType [ cfg.port ];
      })
      (lib.optionalAttrs isDarwin {
        homebrew.casks = lib.mkIf hasPlugins [ "zotero" ];
      })
      {
        environment.systemPackages =
          (lib.optional isDesktopType pkgs.joplin-desktop)
          ++ (lib.optional isCliType pkgs.joplin-cli)
          ++ (lib.optionals hasPlugins [
            pkgs.pandoc
            pkgs.texliveMedium
          ])
          ++ (lib.optionals (hasPlugins && !isDarwin) [
            pkgs.zotero
          ]);

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
                "Library/Application Support/joplin-desktop/plugins/nz.magnusso.zotero-link.jpl".source = zoteroLinkJpl;
              })
            ];
          }
        ];
      }
    ]
  );
}

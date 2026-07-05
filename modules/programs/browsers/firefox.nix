{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.firefox;
  firefox-nightly = inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin;
  enabled = cfg.enable || cfg.nightly.enable;
in
{
  options.myFeatures.programs.browsers.firefox = {
    enable = lib.mkEnableOption "Enables Firefox browser";
    default = lib.mkEnableOption "Set Firefox as the default browser";

    nightly = {
      enable = lib.mkEnableOption "Use Firefox Nightly binary";
    };

    extensions = {
      enable = lib.mkEnableOption "Declarative force-installed extensions";
    };
  };

  config = lib.mkIf enabled {
    programs.firefox = {
      enable = true;
      package = lib.mkIf cfg.nightly.enable (lib.mkForce firefox-nightly);

      policies = {
        ExtensionSettings = lib.mkIf cfg.extensions.enable {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          "{c45c406e-ab73-4d4d-90ee-37297e69bb9f}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/surfshark-vpn-proxy/latest.xpi";
            installation_mode = "force_installed";
          };
          "{7414512c-f056-4740-b333-855146909459}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-Mnnj3D6pJgNwiw@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger/latest.xpi";
            installation_mode = "force_installed";
          };
          "sponsorBlocker@ajay.app" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
          };
          "{9610996c-54a7-471e-be2c-474070a72061}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/chrome-mask/latest.xpi";
            installation_mode = "force_installed";
          };
          "{762f9885-5a13-4abb-9c76-993d3d63b913}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislike/latest.xpi";
            installation_mode = "force_installed";
          };
          "firefox-extension@steamdb.info" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
            installation_mode = "force_installed";
          };
          "@testpilot-containers" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

    home-manager.sharedModules = [
      (
        let
          desktop = if cfg.nightly.enable then "firefox-nightly.desktop" else "firefox.desktop";
        in
        {
          programs.firefox = {
            enable = true;
            profiles = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
              isDefault = name == lib.head config.myFeatures.core.system.users.usernames;
              settings = {
                "browser.download.dir" = "/home/${name}/Downloads";
                "browser.startup.page" = 3;
                "datareporting.healthreport.uploadEnabled" = false;
                "browser.topsites.contile.enabled" = false;
                "browser.newtabpage.activity-stream.showSponsored" = false;
                "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
                "browser.uiCustomization.debug" = lib.mkIf cfg.nightly.enable true;
              };
            });
          };

          home.sessionVariables = lib.mkIf cfg.default {
            BROWSER = if cfg.nightly.enable then "firefox-nightly" else "firefox";
          };

          xdg.mimeApps = lib.mkIf cfg.default {
            enable = true;
            defaultApplications = {
              "text/html" = [ desktop ];
              "x-scheme-handler/http" = [ desktop ];
              "x-scheme-handler/https" = [ desktop ];
              "x-scheme-handler/about" = [ desktop ];
              "x-scheme-handler/unknown" = [ desktop ];
            };
          };
        }
      )
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".mozilla"
              ".config/mozilla"
              ".cache/mozilla"
            ];
          });
        };
  };
}

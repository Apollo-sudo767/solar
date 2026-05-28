{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.firefox;
  firefox-nightly = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin;
in
{
  options.myFeatures.programs.browsers.firefox = {
    enable = lib.mkEnableOption "Enables Firefox browser";

    nightly = {
      enable = lib.mkEnableOption "Use Firefox Nightly binary";
    };

    extensions = {
      enable = lib.mkEnableOption "Declarative force-installed extensions";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-wide Firefox configuration
    programs.firefox = {
      enable = true;

      # Swaps the default Firefox package for Nightly if the submodule toggle is enabled
      package = lib.mkIf cfg.nightly.enable (lib.mkForce firefox-nightly);

      policies = {
        # Conditional extension handling based on your new extension toggle
        ExtensionSettings = lib.mkIf cfg.extensions.enable {
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            # Bitwarden
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          "{c45c406e-ab73-4d4d-90ee-37297e69bb9f}" = {
            # Surfshark
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/surfshark-vpn-proxy/latest.xpi";
            installation_mode = "force_installed";
          };
          "{7414512c-f056-4740-b333-855146909459}" = {
            # ClearURLs
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-Mnnj3D6pJgNwiw@jetpack" = {
            # Privacy Badger
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger/latest.xpi";
            installation_mode = "force_installed";
          };
          "sponsorBlocker@ajay.app" = {
            # SponsorBlock
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
          };
          "{9610996c-54a7-471e-be2c-474070a72061}" = {
            # Chrome Mask
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/chrome-mask/latest.xpi";
            installation_mode = "force_installed";
          };
          "{762f9885-5a13-4abb-9c76-993d3d63b913}" = {
            # Return YouTube Dislike
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/return-youtube-dislike/latest.xpi";
            installation_mode = "force_installed";
          };
          "firefox-extension@steamdb.info" = {
            # SteamDB
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
            installation_mode = "force_installed";
          };
          "@testpilot-containers" = {
            # Multi-Account Containers
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
            installation_mode = "force_installed";
          };
        };
      };
    };

    # User-specific Home Manager configuration via Solar's username generator
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      stylix.targets.firefox.profileNames = lib.mkIf config.stylix.enable [ name ];

      programs.firefox = {
        enable = true;
        profiles.${name} = {
          isDefault = true;
          settings = {
            "browser.download.dir" = "/home/${name}/Downloads";
            "browser.startup.page" = 3;
            "datareporting.healthreport.uploadEnabled" = false;
            "browser.topsites.contile.enabled" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            # UI Debugging for Nova redesign monitoring - active only when Nightly binary is used
            "browser.uiCustomization.debug" = lib.mkIf cfg.nightly.enable true;
          };
        };
      };
    });
  };
}

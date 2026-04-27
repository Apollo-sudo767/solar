{ config, lib, ... }:

let
  cfg = config.myFeatures.programs.browsers.firefox;
in
{
  options.myFeatures.programs.browsers.firefox = {
    enable = lib.mkEnableOption "Enables Firefox";
  };

  config = lib.mkIf cfg.enable {
    # System-wide Firefox configuration and declarative extensions
    programs.firefox = {
      enable = true;
      policies = {
        # Force install requested extensions
        ExtensionSettings = {
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

    # User-specific Home Manager configuration
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      # FORCE the Stylix Home Manager module to load for this specific user
      stylix.targets.firefox.profileNames = [ name ];

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
          };
        };
      };
    });
  };
}

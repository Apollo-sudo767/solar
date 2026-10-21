# modules/programs/browsers/chrome.nix
# ============================================================================
# Chromium / Google Chrome / Ungoogled Chromium Browser Module
# ============================================================================
# Installs and configures a Chromium-family browser (`chromium` by default,
# `ungoogled-chromium` when `ungoogled.enable = true`, or proprietary
# `google-chrome` when `googleChrome.enable = true`) with managed privacy
# policies and default browser MIME associations.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.chrome;
  useGoogleChrome = cfg.googleChrome.enable && !cfg.ungoogled.enable;
  browserPkg =
    if cfg.ungoogled.enable then
      pkgs.ungoogled-chromium
    else if cfg.googleChrome.enable then
      pkgs.google-chrome
    else
      pkgs.chromium;
  browserCmd = if useGoogleChrome then "google-chrome" else "chromium";
  desktopFile = if useGoogleChrome then "google-chrome.desktop" else "chromium-browser.desktop";
in
{
  options.myFeatures.programs.browsers.chrome = {
    enable = lib.mkEnableOption "Enables Chromium-based browsers";
    default = lib.mkOption {
      type = lib.types.bool;
      default =
        !(
          (
            config.myFeatures.programs.browsers.firefox.enable
            || config.myFeatures.programs.browsers.firefox.nightly.enable
          )
          && config.myFeatures.programs.browsers.firefox.default
        );
      description = "Set Chrome/Chromium as the default browser";
    };

    googleChrome = {
      enable = lib.mkEnableOption "Use Google Chrome (proprietary)";
    };

    ungoogled = {
      enable = lib.mkEnableOption "Use Ungoogled Chromium (privacy-hardened)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.chromium = {
      enable = !useGoogleChrome;
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "BuiltInInsecureFormsWarningsEnabled" = true;
      };
    };

    home-manager.sharedModules = [
      {
        programs.chromium = {
          enable = true;
          package = browserPkg;
          extensions = [
            { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
            { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
            { id = "mnjbeadjmkaphoeipkbpcpghpleffbpo"; } # Poster
          ];
        };

        home.sessionVariables = lib.mkIf cfg.default {
          BROWSER = lib.mkDefault browserCmd;
        };

        xdg.mimeApps = lib.mkIf cfg.default {
          enable = true;
          defaultApplications = {
            "text/html" = [ desktopFile ];
            "x-scheme-handler/http" = [ desktopFile ];
            "x-scheme-handler/https" = [ desktopFile ];
            "x-scheme-handler/about" = [ desktopFile ];
            "x-scheme-handler/unknown" = [ desktopFile ];
          };
        };
      }
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".config/chromium"
              ".config/google-chrome"
              ".cache/chromium"
              ".cache/google-chrome"
            ];
          });
        };
  };
}

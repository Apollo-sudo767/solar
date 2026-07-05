{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.chrome;
in
{
  options.myFeatures.programs.browsers.chrome = {
    enable = lib.mkEnableOption "Enables Chromium-based browsers";
    default = lib.mkEnableOption "Set Chrome/Chromium as the default browser";

    googleChrome = {
      enable = lib.mkEnableOption "Use Google Chrome (proprietary)";
    };

    ungoogled = {
      enable = lib.mkEnableOption "Use Ungoogled Chromium (privacy-hardened)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      (
        if cfg.ungoogled.enable then
          pkgs.ungoogled-chromium
        else if cfg.googleChrome.enable then
          pkgs.google-chrome
        else
          pkgs.chromium
      )
    ];

    programs.chromium = {
      enable = true;
      extraOpts = {
        "BrowserSignin" = 0;
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "BuiltInInsecureFormsWarningsEnabled" = true;
      };
    };

    home-manager.sharedModules = [
      (
        let
          browserCmd =
            if cfg.ungoogled.enable then
              "chromium"
            else if cfg.googleChrome.enable then
              "google-chrome"
            else
              "chromium";
          desktopFile =
            if cfg.ungoogled.enable then
              "chromium-browser.desktop"
            else if cfg.googleChrome.enable then
              "google-chrome.desktop"
            else
              "chromium-browser.desktop";
        in
        {
          programs.chromium = {
            enable = true;
            extensions = [
              { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
              { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
              { id = "mnjbeadjmkaphoeipkbpcpghpleffbpo"; } # Poster
            ];
          };

          home.sessionVariables = lib.mkIf cfg.default {
            BROWSER = browserCmd;
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
      )
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

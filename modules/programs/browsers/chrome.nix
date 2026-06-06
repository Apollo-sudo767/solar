{
  config,
  lib,
  pkgs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.browsers.chrome;
in
{
  options.myFeatures.programs.browsers.chrome = {
    enable = lib.mkEnableOption "Enables Chromium-based browsers";

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
      {
        programs.chromium = {
          enable = true;
          extensions = [
            { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
            { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
            { id = "mnjbeadjmkaphoeipkbpcpghpleffbpo"; } # Poster
          ];
        };
      }
    ];
  };
}

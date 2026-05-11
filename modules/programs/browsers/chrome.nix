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

    googleChrome = {
      enable = lib.mkEnableOption "Use Google Chrome (proprietary)";
    };

    ungoogled = {
      enable = lib.mkEnableOption "Use Ungoogled Chromium (privacy-hardened)";
    };
  };

  config = lib.mkIf cfg.enable {
    # System-wide configuration for Chromium-based browsers
    programs.chromium = {
      enable = true;

      # Select the package based on the enabled submodule
      package =
        if cfg.ungoogled.enable then
          pkgs.ungoogled-chromium
        else if cfg.googleChrome.enable then
          pkgs.google-chrome
        else
          pkgs.chromium;

      # Global policies for all Chromium-based instances
      extraOpts = {
        "BrowserSignin" = 0; # Disable browser sign-in
        "SyncDisabled" = true;
        "PasswordManagerEnabled" = false;
        "BuiltInInsecureFormsWarningsEnabled" = true;
      };
    };

    # User-specific configuration via Solar's username generator
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
      # Integration with Stylix for consistent system-wide theming
      stylix.targets.chromium.enable = true;

      programs.chromium = {
        enable = true;
        # Declarative extensions for Chromium-based browsers
        extensions = [
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
          { id = "mnjbeadjmkaphoeipkbpcpghpleffbpo"; } # Poster (for Nova-like API testing)
        ];
      };
    });
  };
}

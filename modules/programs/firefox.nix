{ config, lib, ...  }:
let
  cfg = config.myFeatures.programs.firefox;
in
{
  options.myFeatures.programs.firefox = {
    enable = lib.mkEnableOption "Enables Firefox"
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.enable = true;

    home-manager.users.apollo = {
      programs.firefox = {
        enable = true;
        profiles.apollo = {
          isDefault = true;
          # Add your custom Mizzou/School bookmarks or settings here
          settings = {
            "browser.download.dir" = "/home/apollo/Downloads";
            "browser.startup.page" = 3; # Resume previous session
          };
        };
      };
    };
  };
}

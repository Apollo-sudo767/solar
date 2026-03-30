{ config, lib, inputs, ... }: # Add 'inputs' to the arguments here

let
  cfg = config.myFeatures.programs.firefox;
in
{
  options.myFeatures.programs.firefox = {
    enable = lib.mkEnableOption "Enables Firefox";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox.enable = true;

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

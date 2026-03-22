{ config, lib, ... }:

let
  cfg = config.myFeatures.programs.firefox;
in
{
  options.myFeatures.programs.firefox = {
    enable = lib.mkEnableOption "Enables Firefox";
  };

  config = lib.mkIf cfg.enable {
    # System-level enable
    programs.firefox.enable = true;

    # FIX: Dynamic multi-user mapping
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      stylix.targets.firefox.profileNames = [ "${name}" ];
      programs.firefox = {
        enable = true;
        # Creates a profile named after the user (e.g., 'apollo' or 'aidan')
        profiles.${name} = {
          isDefault = true;
          settings = {
            "browser.download.dir" = "/home/${name}/Downloads";
            "browser.startup.page" = 3; # Resume previous session
            
            # Privacy and Bloat-removal (Optional Phanes parity)
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

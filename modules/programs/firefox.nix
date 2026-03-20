{ ... }: {
  flake.nixosModules.myFeatures.firefox = { pkgs, ... }: {
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

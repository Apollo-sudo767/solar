{ config, lib, pkgs, ... }:

let
  usernames = config.myFeatures.core.users.usernames;
in {
  options.myFeatures.programs.helix.enable = lib.mkEnableOption "Helix Editor";

  config = lib.mkIf config.myFeatures.programs.helix.enable {
    home-manager.users = lib.genAttrs usernames (name: {
      programs.helix = {
        enable = true;
        # Use mkForce to override Stylix's automatic theme
        settings = {
          theme = lib.mkForce "gruvbox"; 
          editor = {
            line-number = "relative";
            cursor-shape = {
              insert = "bar";
              normal = "block";
            };
          };
        };
      };
    });
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.platforms.addons.fuzzel;
  usernames = lib.filter (n: n != "enable" && n != "usernames") config.myFeatures.core.users.usernames;
in
{
  options.myFeatures.platforms.addons.fuzzel = {
    enable = lib.mkEnableOption "Fuzzel according to stylix";
  };
  
  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs usernames (name: {
      # This allows Stylix to take over Fuzzel styling 
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            terminal = "${pkgs.ghostty}/bin/ghostty";
            layer = "overlay";
            # Force the font and radius to match your flush look
            font = lib.mkForce "JetBrainsMono Nerd Font:size=11";
          };
          border.radius = lib.mkForce 0; 
        };
      };
    });
  };
}

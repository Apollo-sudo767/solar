{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.programs.davinci;
in
{
  options.myFeatures.programs.davinci.enable = lib.mkEnableOption "Enable Davinci-resolve";

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      home.packages = [ 
        pkgs.davinci-resolve 
      ];
      
    });
  };
}

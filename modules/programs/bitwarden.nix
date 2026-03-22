{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.bitwarden;
in
{
  options.myFeatures.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden Stack";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bitwarden
      bitwarden-cli
      goldwarden
      pinentry-gnome3
    ];

    services.dbus.enable = true;
    security.polkit.enable = true;

    # FIX: Only map over the list of strings in .usernames
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
      programs.rbw = {
        enable = true;
        settings = {
          email = "fireshifter767@gmail.com";
          pinentry = pkgs.pinentry-gnome3;
        };
      };
      home.packages = [ pkgs.bitwarden ];
    });
  };
}

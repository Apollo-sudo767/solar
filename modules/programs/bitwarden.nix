{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.bitwarden;
in
{
  options.myFeatures.programs.bitwarden.enable = lib.mkEnableOption "Bitwarden Stack";

  config = lib.mkIf cfg.enable {
    # 1. System-wide packages (Migrated from Phanes desktop.nix)
    environment.systemPackages = with pkgs; [
      bitwarden          # Official Desktop GUI
      bitwarden-cli      # Official 'bw' CLI
      goldwarden         # Background Daemon for seamless unlocking
      pinentry-gnome3    # Required for rbw/bitwarden to prompt for passwords
    ];

    # 2. Enable Goldwarden Daemon
    services.goldwarden.enable = true;
    services.dbus.enable = true;
    security.polkit.enable = true;

    # 3. Home Manager block for rbw & User Config
    home-manager.users = lib.mapAttrs (name: _: {
      # rbw: The Rust Bitwarden client you liked in Phanes
      programs.rbw = {
        enable = true;
        settings = {
          email = "fireshifter767@gmail.com";
          pinentry = pkgs.pinentry-gnome3;
        };
      };

      # Ensure the Bitwarden desktop app is easily discoverable
      home.packages = [ pkgs.bitwarden ];
    }) config.myFeatures.users;
  };
}

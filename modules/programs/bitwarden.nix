{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.bitwarden;
in
{
  options.myFeatures.programs.bitwarden = {
    enable = lib.mkEnableOption "Bitwarden and Goldwarden Integration";
  };

  config = lib.mkIf cfg.enable {
    # 1. Install the essential toolset
    environment.systemPackages = with pkgs; [
      bitwarden          # The GUI Desktop Application
      bitwarden-cli      # The 'bw' command line tool
      goldwarden         # The specialized background daemon
    ];

    # 2. Enable the Goldwarden Service
    # This is the "special NixOS thing" that keeps your vault unlocked 
    # and syncs it with your browser and terminal automatically.
    services.goldwarden.enable = true;

    # 3. Security & Auth integration
    # Required for Goldwarden to prompt you for your password or system auth
    security.polkit.enable = true;
    
    # Ensures Goldwarden can communicate with your browsers (Zen/Firefox)
    # for the auto-fill and "unlock with biometrics" features.
    services.dbus.enable = true;
  };
}

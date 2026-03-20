{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.programs.ghostty;
in
{
  options.myFeatures.programs.ghostty.enable = lib.mkEnableOption "Ghostty Terminal Emulator";

  config = lib.mkIf cfg.enable {
    # 1. System-level installation
    # Since Ghostty is often a flake input or in bleeding-edge nixpkgs:
    environment.systemPackages = [ 
      # If you have it in your flake inputs:
      # inputs.ghostty.packages.${pkgs.system}.default 
      # Or from standard nixpkgs:
      pkgs.ghostty 
    ];

    # 2. Home Manager Configuration (The "Feel")
    home-manager.users = lib.mapAttrs (name: _: {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          # Phanes Parity: Clean look
          window-padding-x = 10;
          window-padding-y = 10;
          window-decoration = false;
          confirm-close-surface = false;
          
          # Stylix will automatically handle the Gruvbox colors and 
          # JetBrains Mono font if you have Stylix enabled!
        };
      };
    }) config.myFeatures.users;
  };
}

{ config, lib, pkgs, inputs, ... }:

let
  # 1. Setup a shortcut to your feature's config
  # Replace 'myFeature' with your actual feature name
  cfg = config.myFeatures.hardware.pi3;
in
{
  # --- OPTIONS ---
  # This defines the "switches" you flip in your /hosts files
  options.myFeatures.hardware.pi3 = {
    enable = lib.mkEnableOption "Hardware Settings for Pi 3";
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
  config = lib.mkIf cfg.enable {
      # SD Image Specifics
    sdImage.compressImage = true;
    zramSwap.enable = true;
    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
    # Set the architecture for the image
    nixpkgs.hostPlatform = "aarch64-linux";
    users.users.apollo.hashedPassword = "$6$uEe7O.pykcuIaZVc$oCGnxu68r7wpVkOAhJiXC.TGDwE6kETEYQTWCl.Y1Vsxn21WgRkjsuv0sTXB0ygf1duIJytQ6h3TgLmjVuKbr/";
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.core.boot;
  # Points to your assets folder relative to this file
  wallpaper = ../../assets/wallpapers/limine-bg.png;
in
{
  options.myFeatures.core.boot = {
    enable = lib.mkEnableOption "Limine Bootloader";
  };

  config = lib.mkIf cfg.enable {
    # Disable the default systemd-boot to make room for Limine
    boot.loader.systemd-boot.enable = false;
    
    # Enable UEFI support
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.limine = {
      enable = true;
      enableEditor = false; # Keeps the boot menu clean
      
      # Use the background image from your Phanes assets
      style.wallpapers = {
        inherit wallpaper;
      };
    };

    # Essential system packages for managing boot entries if needed
    environment.systemPackages = with pkgs; [
      limine
      efibootmgr
    ];
  };
}

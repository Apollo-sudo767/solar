{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.core.boot.boot;
  # Points to your assets folder relative to this file
  wallpaperPath = ../../../assets/wallpapers/limine-bg.png;
in
{
  options.myFeatures.core.boot.boot = {
    enable = lib.mkEnableOption "Limine Bootloader";
  };

  config = lib.mkIf cfg.enable {
    # Disable the default systemd-boot to make room for Limine
    boot.loader.systemd-boot.enable = false;

    # Enable UEFI support
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.limine = {
      enable = true;

      # FIX: Wrap the path in a list [ ] and remove the attribute name
      style = {
        wallpapers = [ wallpaperPath ];
        wallpaperStyle = "stretched";
      };
    };

    boot.kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];

    boot.plymouth.enable = true;
    environment.systemPackages = with pkgs; [
      limine
      efibootmgr
    ];
  };
}

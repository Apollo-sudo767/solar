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

      style = {
        wallpapers = lib.mkForce [ wallpaperPath ];
        wallpaperStyle = "stretched";
      };
    };

    # The native "Nix-Way" to pass compression properties to the initrd builder engine
    boot.initrd.compressor = "zstd";

    # Strip out non-essential module footprints from the early RAM disk phase
    boot.initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    boot.kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];

    boot.plymouth.enable = true;

    # Clean alternative to generationLimit: Prevent profile bloating inside /boot
    # by automatically sweeping up older generations on a predictable schedule.
    nix.gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };

    environment.systemPackages = with pkgs; [
      limine
      efibootmgr
    ];

    hardware.enableAllFirmware = true;
    hardware.firmware = [ pkgs.linux-firmware ];
  };
}

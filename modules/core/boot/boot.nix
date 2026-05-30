{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  options.myFeatures.core.boot = {
    boot.enable = lib.mkEnableOption "Common Bootloader configuration";
    loader = lib.mkOption {
      type = lib.types.enum [
        "limine"
        "grub"
        "systemd"
      ];
      default = "limine";
      description = "The bootloader to use.";
    };
    secureBoot = {
      enable = lib.mkEnableOption "Native Bootloader Secure Boot";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.boot.enable) {
    # Enable UEFI support
    boot.loader.efi.canTouchEfiVariables = true;

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

    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = [ pkgs.linux-firmware ];
  };
}

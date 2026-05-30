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
    kernel = lib.mkOption {
      type = lib.types.enum [
        "default"
        "latest"
        "zen"
        "xanmod"
      ];
      default = "default";
      description = "The kernel package to use.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.boot.enable) {
    # Kernel Selection
    boot.kernelPackages =
      if cfg.kernel == "latest" then
        pkgs.linuxPackages_latest
      else if cfg.kernel == "zen" then
        pkgs.linuxPackages_zen
      else if cfg.kernel == "xanmod" then
        pkgs.linuxPackages_xanmod
      else
        pkgs.linuxPackages;

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

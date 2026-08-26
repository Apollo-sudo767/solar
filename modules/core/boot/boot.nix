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
    resolution = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Framebuffer / GOP display resolution for the bootloader (e.g. '2560x1440', '1920x1080'). If null, bootloader chooses default.";
    };
    timeout = lib.mkOption {
      type = lib.types.int;
      default = 1;
      description = "Bootloader menu timeout in seconds.";
    };
    plymouth = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Plymouth graphical boot splash.";
      };
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

    system.boot.loader.kernelFile =
      let
        kernelDir = config.boot.kernelPackages.kernel;
      in
      if builtins.pathExists "${kernelDir}/vmlinuz" then
        "vmlinuz"
      else if (kernelDir ? target) then
        kernelDir.target
      else
        "bzImage";

    # Enable UEFI support
    boot.loader.efi.canTouchEfiVariables = true;

    # Bootloader timeout optimization
    boot.loader.timeout = lib.mkDefault cfg.timeout;

    # Fast boot optimizations
    systemd.services.NetworkManager-wait-online.enable = lib.mkDefault false;

    # Prevent journal log bloat from slowing down systemd-tmpfiles-setup.service
    services.journald.extraConfig = ''
      SystemMaxUse=200M
      MaxRetentionSec=14d
    '';

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

    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.tpm2.enable = true;

    boot.kernelParams = [
      "quiet"
      "loglevel=3"
      "systemd.show_status=auto"
      "rd.udev.log_level=3"
    ];

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    boot.plymouth.enable = lib.mkDefault cfg.plymouth.enable;

    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = [ pkgs.linux-firmware ];

    # Clean alternative to generationLimit: Prevent profile bloating inside /boot
    # by automatically sweeping up older generations on a predictable schedule.
    nix.gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}

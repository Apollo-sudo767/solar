# modules/core/boot/boot.nix
# ============================================================================
# Common Linux Kernel, Initrd & Boot Optimization Module
# ============================================================================
# Configures the Linux kernel variant (`default`, `latest`, `zen`, `xanmod`),
# systemd-based zstd-compressed initrd with TPM2 support, BBR TCP congestion
# control, Plymouth splash screen, journald size caps, and redistributable
# Linux hardware firmware.
# (Note: Automatic weekly garbage collection to keep `/boot` clean is configured
# canonically in `modules/core/nix/nix-settings.nix`.)
{
  config,
  lib,
  pkgs,
  options,
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
      description = "The UEFI bootloader to use.";
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
      description = "The Linux kernel package variant to use.";
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
    # 1. Kernel Variant Selection
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

    # 2. UEFI & Bootloader Defaults
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
    boot.loader.timeout = lib.mkDefault cfg.timeout;

    # 3. Fast Boot & Journald Cap Optimizations
    systemd.services.NetworkManager-wait-online.enable = lib.mkDefault false;

    # Cap systemd-journald disk usage to prevent slow boot-time tmpfiles scans
    services.journald =
      if (options.services.journald ? settings) then
        {
          settings.Journal = {
            SystemMaxUse = "200M";
            MaxRetentionSec = "14d";
          };
        }
      else
        {
          extraConfig = ''
            SystemMaxUse=200M
            MaxRetentionSec=14d
          '';
        };

    # 4. Early RAM Disk (Initrd) & TPM2 Configuration
    boot.initrd.compressor = "zstd";
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

    # 5. Quiet Boot & Network Stack Tuning (TCP BBR + fq qdisc)
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

    # 6. Redistributable Hardware Firmware
    hardware.enableAllFirmware = lib.mkDefault false;
    hardware.enableRedistributableFirmware = true;
    hardware.firmware = [ pkgs.linux-firmware ];
  };
}

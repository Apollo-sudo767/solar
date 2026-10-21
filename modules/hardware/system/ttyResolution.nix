# modules/hardware/system/ttyResolution.nix
# ============================================================================
# Virtual Console (TTY) & Bootloader Framebuffer Resolution
# ============================================================================
# Configures the kernel KMS `video=` mode and UEFI bootloader framebuffer
# resolution (`limine`, `systemd-boot`, `grub`) so early boot prompts (LUKS),
# virtual consoles (TTY1-6), and TUI login managers (`tuigreet`) render at
# the display's native resolution instead of a stretched low-res fallback.
{ config, lib, ... }:

let
  cfg = config.myFeatures.hardware.system.ttyResolution;
in
{
  options.myFeatures.hardware.system.ttyResolution = {
    enable = lib.mkEnableOption "TTY Resolution configuration";
    resolution = lib.mkOption {
      type = lib.types.str;
      default =
        if config.myFeatures.core.boot.resolution != null then
          config.myFeatures.core.boot.resolution
        else
          "2560x1440";
      description = "The resolution to set for the TTY and bootloader framebuffer (e.g., '2560x1440', '1920x1080').";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "video=${cfg.resolution}" ];
    boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
    boot.loader.grub.gfxmodeEfi = lib.mkDefault "${cfg.resolution},auto";
    boot.loader.limine.resolution = lib.mkDefault cfg.resolution;
  };
}

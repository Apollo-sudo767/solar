# modules/core/boot/grub.nix
# ============================================================================
# GRUB UEFI Bootloader (`myFeatures.core.boot.loader = "grub"`)
# ============================================================================
# Linux-only module (omits `isDarwin`/`isTotal` so the Dendritic scanner skips
# it on macOS). Configures GRUB for UEFI systems when `loader = "grub"`.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "grub") {
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
  };
}

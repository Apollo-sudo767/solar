# modules/core/boot/boot-branch.nix
# ============================================================================
# Bootloader Selection Branch (`myFeatures.core.boot`)
# ============================================================================
# Entrypoint for Linux boot configuration. Enabling `myFeatures.core.boot.enable = true;`
# turns on the common kernel/initrd optimizations (`boot.nix`) and defaults the
# UEFI bootloader to Limine (`limine.nix`).
{
  lib,
  config,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  options.myFeatures.core.boot.enable = lib.mkEnableOption "Bootloader Selection Branch";

  config = lib.mkIf cfg.enable {
    myFeatures.core.boot.boot.enable = lib.mkDefault true;
    myFeatures.core.boot.loader = lib.mkDefault "limine";
  };
}

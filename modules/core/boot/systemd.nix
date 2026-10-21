# modules/core/boot/systemd.nix
# ============================================================================
# systemd-boot UEFI Bootloader (`myFeatures.core.boot.loader = "systemd"`)
# ============================================================================
# Enables `systemd-boot` with maximum UEFI console resolution (`consoleMode = "max"`).
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.core.boot;
in
{
  config = lib.mkIf (cfg.enable && cfg.loader == "systemd") {
    boot.loader.systemd-boot = {
      enable = true;
      consoleMode = lib.mkDefault "max";
    };
  };
}

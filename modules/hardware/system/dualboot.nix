# modules/hardware/system/dualboot.nix
# ============================================================================
# Windows EFI Chainload Entry for Limine (`dualboot`)
# ============================================================================
# Adds a `/Windows` chainload menu entry to the Limine bootloader pointing to
# the Windows Boot Manager (`bootmgfw.efi`) on a dual-boot system.
{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.hardware.system.dualboot;
in
{
  options.myFeatures.hardware.system.dualboot = {
    enable = lib.mkEnableOption "Windows EFI Dualboot chainloading in Limine";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.limine = {
      extraEntries = ''
        /Windows
          protocol: efi_chainload
          image_path: guid(46ad5651-bf48-40a1-8a92-a8a1c377e009):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };
}

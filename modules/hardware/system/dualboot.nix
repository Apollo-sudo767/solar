{ config, lib, ... }:

let
  # 1. Setup a shortcut to your feature's config
  cfg = config.myFeatures.hardware.system.dualboot;
in
{
  # --- OPTIONS ---
  options.myFeatures.hardware.system.dualboot = {
    enable = lib.mkEnableOption "Enables Windows Dualboot on Mars";
  };

  # --- CONFIG ---
  # Shield the payload from macOS using optionalAttrs
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

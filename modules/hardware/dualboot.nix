{ config, lib, pkgs, inputs, ... }:

let
  # 1. Setup a shortcut to your feature's config
  # Replace 'myFeature' with your actual feature name
  cfg = config.myFeatures.hardware.dualboot;
in
{
  # --- OPTIONS ---
  # This defines the "switches" you flip in your /hosts files
  options.myFeatures.hardware.dualboot = {
    enable = lib.mkEnableOption "Enables Windows Dualboot on Mars";
  };

  # --- CONFIG ---
  # This is the "payload" that only runs if 'enable' is true
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

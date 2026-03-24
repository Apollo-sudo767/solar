{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.hardware.p1dualboot;
in
{
  # --- OPTIONS ---
  options.myFeatures.hardware.p1dualboot = {
    enable = lib.mkEnableOption "Enables Windows Dualboot on Mars";
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    boot.loader.limine = {
      extraEntries = ''
        +Windows
            protocol: efi_chainload
            # We add the /EFI/ prefix explicitly
            image_path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };
}

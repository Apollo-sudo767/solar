{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.hardware.p1dualboot;
in
{
  # --- OPTIONS ---
  options.myFeatures.hardware.p1dualboot = {
    enable = lib.mkEnableOption "Enables Windows Dualboot on Europa";
  };

  # --- CONFIG ---
  config = lib.mkIf cfg.enable {
    boot.loader.limine = {
      # Allows pressing 'E' to edit the entry at boot if needed
      enableEditor = true;

      extraEntries = ''
        :Windows
            protocol: efi_chainload
            # Explicitly pointing to the EFI partition via its PARTUUID
            path: guid(048d93bb-58b4-432d-97b6-a8efc3d81977):/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };
}

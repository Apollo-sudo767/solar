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
      # This allows you to press 'E' at the boot screen if we need to debug
      enableEditor = true;

      extraEntries = ''
        :Windows
            protocol: efi_chainload
            # boot(): refers to the partition Limine was loaded from (the ESP)
            path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };
}

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
      editor_enabled = true;

      extraEntries = ''
        + Windows
            protocol: efi_chainload
            # Since they share a partition, boot(): starts at the root of that drive
            image_path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };
}

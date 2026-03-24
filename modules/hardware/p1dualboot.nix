{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.hardware.p1dualboot;
in
{
  options.myFeatures.hardware.p1dualboot = {
    enable = lib.mkEnableOption "Enables Windows Dualboot on Mars";
  };

  config = lib.mkIf cfg.enable {
    boot.loader.limine = {
      extraEntries = ''
        :Windows
         protocol: efi_chainload
         image_path: uuid://FA0B-D29A/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };
}

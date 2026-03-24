config = lib.mkIf cfg.enable {
    boot.loader.limine = {
      extraEntries = ''
        :Windows
        protocol: efi_chainload
        image_path: uuid://FA0B-D29A/EFI/Microsoft/Boot/bootmgfw.efi
      '';
    };
  };

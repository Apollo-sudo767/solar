{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usb_storage"
    "sd_mod"
    "sdhci_pci"
    "mmc_block"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Standard eMMC / SSD Root Partition
  # Using labels is safer for portable devices
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXOS_BOOT";
    fsType = "vfat";
  };

  # SD Card Automount for Games
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/GAMES";
    fsType = "auto";
    options = [ 
      "nofail" 
      "x-systemd.automount" 
      "x-systemd.idle-timeout=60" # Unmount if idle to save power/prevent corruption
    ];
  };

  swapDevices = [ ];

  # Intel Atom Specifics
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

# Clean hardware-configuration.nix for Disko-managed systems
{ lib, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # CPU microcode
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
  
  # Disko handles fileSystems, swapDevices, and luks mapping now.
}

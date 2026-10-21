# modules/hosts/mars/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Mars (Primary AMD + NVIDIA Desktop Workstation)
# ==============================================================================
# Declares AMD KVM (`kvm-amd`), CPU microcode updates, and initrd storage/USB
# drivers. Disko manages all filesystems, swap, and LUKS encryption.
# ==============================================================================

{ lib, config, ... }:

{
  boot.initrd.availableKernelModules = [
    "nvme"
    "ahci"
    "xhci_pci"
    "usb_storage"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # CPU microcode
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Disko handles fileSystems, swapDevices, and luks mapping now.
}

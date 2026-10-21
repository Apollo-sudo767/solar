# modules/hosts/pluto/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Pluto (Beelink EQR5, AMD Ryzen 7 5825U)
# ==============================================================================
# Declares AMD virtualization (`kvm-amd`), microcode updates, and initrd PCIe/
# SATA/NVMe/Realtek NIC modules. Storage layout is managed by Disko.
# ==============================================================================

{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "r8169" # Realtek Gigabit / 2.5GbE Ethernet
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Platform & Microcode
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

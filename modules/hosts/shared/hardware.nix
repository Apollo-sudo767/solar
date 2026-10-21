# modules/hosts/shared/hardware.nix
# ==============================================================================
# Shared Intel x86_64 Hardware Baseline
# ==============================================================================
# Common kernel modules, initrd storage drivers, KVM virtualization, and CPU
# microcode settings shared across Intel-based NixOS hosts.
# Hosts that import this module only need to declare host-specific network/HBA
# initrd modules, extra kernel modules, or non-Disko filesystem mounts.
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

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
      "sdhci_pci"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  # CPU/Platform Specifics
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

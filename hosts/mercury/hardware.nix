{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ]; #
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ]; #
    extraModulePackages = [ ]; #
  };

  # CPU/Platform Specifics
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux"; #
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware; #
}

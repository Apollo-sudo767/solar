# modules/hosts/styx/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Styx (Lenovo ThinkCentre M920q Tiny, Intel i5-9500T)
# ==============================================================================
# Extends `../shared/hardware.nix` with SATA AHCI and Intel I219-LM (`e1000e`)
# initrd drivers. Disk partitioning and mounts are managed by Disko.
# ==============================================================================

_:

{
  imports = [
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "e1000e" # Intel I219-LM Gigabit Ethernet
  ];
}

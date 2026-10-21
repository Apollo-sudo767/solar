# modules/hosts/sol/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Sol (Central ZFS NAS & Storage Server)
# ==============================================================================
# Extends `../shared/hardware.nix` with SATA AHCI, SAS/SATA HBA (`mpt3sas`),
# and Intel/Realtek NIC initrd drivers.
# ==============================================================================

_:

{
  imports = [
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "e1000e"
    "r8169"
    "mpt3sas" # SAS/SATA HBA controller support
  ];
}

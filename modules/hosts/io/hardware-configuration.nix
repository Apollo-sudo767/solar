# modules/hosts/io/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Io (Intel Desktop Workstation)
# ==============================================================================
# Extends `../shared/hardware.nix` with SATA AHCI and USB HID initrd modules.
# Disko handles fileSystems and swapDevices declaratively.
# ==============================================================================

_:

{
  imports = [
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "usbhid"
  ];
}

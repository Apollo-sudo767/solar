# modules/hosts/thebe/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Thebe (Intel Mac Mini Server)
# ==============================================================================
# Extends `../shared/hardware.nix` with Apple SMC/GMUX kernel modules, Broadcom
# Gigabit Ethernet (`tg3`) in initrd, and Apple keyboard fnmode quirks.
# ==============================================================================

_:

{
  imports = [
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "usbhid"
    "tg3" # Broadcom Gigabit Ethernet
  ];
  boot.kernelModules = [
    "applesmc" # Apple System Management Controller (fan/temp control)
    "apple_gmux"
  ];

  # Apple Keyboard Quirk: Default to standard F1-F12 keys instead of media keys
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';
}

# modules/hosts/mercury/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Mercury (Intel Laptop Workstation)
# ==============================================================================
# Uses the shared Intel x86_64 hardware baseline (`../shared/hardware.nix`).
# Disko declaratively manages filesystems, swap, and LUKS encryption.
# ==============================================================================

_:

{
  imports = [
    ../shared/hardware.nix
  ];
}

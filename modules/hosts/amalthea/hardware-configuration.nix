# modules/hosts/amalthea/hardware-configuration.nix
# ==============================================================================
# Hardware Configuration — Amalthea (Handheld Gaming Device, Intel Atom x5-Z8350)
# ==============================================================================
# Extends `../shared/hardware.nix` with eMMC/SD block storage support (`mmc_block`)
# and an on-demand systemd automount for the removable `/mnt/games` SD card.
# ==============================================================================

_:

{
  imports = [
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [
    "mmc_block"
  ];

  # SD Card Automount for Games
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/GAMES";
    fsType = "auto";
    options = [
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60" # Unmount if idle to save power/prevent corruption
    ];
  };

  swapDevices = [ ];
}

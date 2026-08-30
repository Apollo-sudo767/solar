# Adding a New Host 🍼

Adding a new machine to the Solar flake is fast, declarative, and automated.

______________________________________________________________________

## 📋 Step 1: Create Host Directory

Create a directory named after your chosen celestial body:

```bash
mkdir -p modules/hosts/<hostname>
```

______________________________________________________________________

## 💻 Step 2: Create `hardware-configuration.nix`

Include hardware drivers and CPU microcode in `modules/hosts/<hostname>/hardware-configuration.nix`:

```nix
{ config, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ]; # or "kvm-amd"
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

______________________________________________________________________

## 🧩 Step 3: Create `default.nix` (with inline `meta` and `module`)

Define the host metadata (`system`, `stable`, `useSolarSecrets`) and enable features in `modules/hosts/<hostname>/default.nix`:

```nix
{
  # 1. Host Metadata (used by flake.nix and modules/hosts/default.nix)
  meta = {
    system = "x86_64-linux"; # or "aarch64-linux", "aarch64-darwin"
    stable = false;          # true for nixpkgs-stable, false for nixpkgs-unstable
    useSolarSecrets = false; # set true to decrypt private secrets with agenix
    useSecrets = false;
  };

  # 2. Host System Module
  module = { config, lib, pkgs, ... }: {
    imports = [ ./hardware-configuration.nix ];
    system.stateVersion = "26.11";

    myFeatures = {
      # 🌲 High-Level Functional Suites
      suites = {
        workstation.enable = true;
        gaming.enable = true;
        desktops.niri.enable = true;
      };

      # 🎛️ Host Storage & Disks
      core.system.disko.speedDisks = [ "/dev/nvme0n1" ];

      # ⚙️ Hardware Drivers
      hardware.cpu-gpu.intel.enable = true;

      # 🎨 Host Styling & Display Manager (Strictly Host-Managed)
      platforms.styling = {
        stylix.enable = true;
        flavors.sky.enable = true;
      };
      platforms.addons.displayManager.manager = "regreet";
    };
  };
}
```

______________________________________________________________________

## 🔍 Step 4: Test Evaluation

Verify that the flake automatically discovers and evaluates your new host:

```bash
git add modules/hosts/<hostname>
nix eval .#nixosConfigurations.<hostname>.config.networking.hostName
```

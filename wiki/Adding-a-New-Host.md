# Adding a New Host 🍼

Adding a new machine to the Solar flake is fast and automated.

______________________________________________________________________

## 📋 Step 1: Create Host Directory

Create a directory named after your chosen celestial body:

```bash
mkdir -p modules/hosts/<hostname>
```

______________________________________________________________________

## ⚙️ Step 2: Create `meta.nix`

Define the target architecture and configuration channels in `modules/hosts/<hostname>/meta.nix`:

```nix
{
  system = "x86_64-linux"; # or "aarch64-linux", "aarch64-darwin"
  stable = false;          # true for nixpkgs-stable, false for nixpkgs-unstable
  useSolarSecrets = false; # set false for standalone hosts without private secrets
  useSecrets = false;
}
```

______________________________________________________________________

## 💻 Step 3: Create `hardware-configuration.nix`

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

## 🧩 Step 4: Create `default.nix`

Enable your desired features in `modules/hosts/<hostname>/default.nix`:

```nix
{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = false;
    useSecrets = false;
  };

  module = { config, lib, pkgs, ... }: {
    imports = [ ./hardware-configuration.nix ];
    system.stateVersion = "26.11";

    myFeatures = {
      core = {
        system.core-branch.enable = true;
        system.disko.speedDisks = [ "/dev/nvme0n1" ];
        system.users.usernames = [ "apollo" ];
        boot = {
          enable = true;
          loader = "limine";
        };
        security.security.enable = true;
        security.ssh.enable = true;
        security.agenix.enable = false;
        nix.lix.enable = true;
      };

      hardware.cpu-gpu.intel.enable = true;
      programs.terminal.ghostty.enable = true;
      services.networking.tailscale.enable = true;
    };
  };
}
```

______________________________________________________________________

## 🔍 Step 5: Test Evaluation

Verify that the flake automatically discovers and evaluates your new host:

```bash
git add modules/hosts/<hostname>
nix eval .#nixosConfigurations.<hostname>.config.networking.hostName
```

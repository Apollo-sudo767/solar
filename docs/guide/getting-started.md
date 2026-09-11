# Getting Started & Deployment 🚀

Solar provides a unified configuration workflow for personal workstations, laptops, Apple Silicon MacBooks, and headless servers.

______________________________________________________________________

## ⚡ Live Installer Image & Disko Deployment

Solar supports direct bare-metal deployment either via the **Solar Live Installer Image** or manually from a standard **NixOS Minimal Live USB**:

```bash
# 1. Boot target hardware into the Solar Live Installer USB
# 2. Run the on-device installer wizard:
sudo solar-install

# Or partition and format directly via Disko:
sudo nix run github:nix-community/disko -- --mode zap-create-mount --flake "github:Apollo-sudo767/solar#<hostname>"
```

______________________________________________________________________

## 🛠️ Manual Installation from Live USB

For local bare-metal provisioning directly from a target machine:

### 1. Boot Live Media

Boot target machine into the official [NixOS Minimal ISO](https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso).

### 2. Format & Partition with Disko

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko \
  --flake "github:Apollo-sudo767/solar#<hostname>"
```

### 3. Generate Hardware Config & Install

```bash
# Generate hardware configuration
sudo nixos-generate-config --no-filesystems --root /mnt

# Copy configuration into your repo branch
mkdir -p /mnt/persist/etc/nixos/modules/hosts/<hostname>
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/persist/etc/nixos/modules/hosts/<hostname>/

# Install NixOS system closure
sudo nixos-install --flake "github:Apollo-sudo767/solar#<hostname>" --no-root-passwd
```

______________________________________________________________________

## 🖥️ Desktop Host Blueprint

Desktop and laptop configurations enable Wayland compositors, GPU drivers, audio, and styling:

```nix
# modules/hosts/<hostname>/default.nix
{
  meta = {
    system = "x86_64-linux";
    useSolarSecrets = true;
  };

  module = { config, lib, pkgs, ... }: {
    imports = [ ./hardware-configuration.nix ];
    system.stateVersion = "26.11";

    myFeatures = {
      core = {
        system = {
          core-branch.enable = true;
          usePersistence = true; # Ephemeral tmpfs root
          users.usernames = [ "apollo" ];
          disko = {
            enable = true;
            enableLuks = true;
            speedDisks = [ "/dev/nvme0n1" ];
          };
        };
        boot = {
          enable = true;
          loader = "limine";
        };
        security = {
          security.enable = true;
          useAppArmor = true;
          ssh.enable = true;
          agenix.enable = true;
        };
      };

      # Desktop & Compositor
      platforms = {
        desktops.niri.enable = true;
        addons.displayManager.manager = "regreet";
      };

      styling = {
        stylix.enable = true;
        themes.sky.enable = true;
      };
    };
  };
}
```

______________________________________________________________________

## 🖧 Server Host Blueprint

Headless servers disable display managers, enable remote WireGuard mesh networking, and set strict security defaults:

```nix
# modules/hosts/<hostname>/default.nix
{
  meta = {
    system = "x86_64-linux";
    useSolarSecrets = true;
  };

  module = { config, lib, pkgs, ... }: {
    imports = [ ./hardware-configuration.nix ];
    system.stateVersion = "26.11";

    myFeatures = {
      core = {
        system = {
          core-branch.enable = true;
          usePersistence = false; # Standard persistent Btrfs root
          users.usernames = [ "apollo" ];
          disko = {
            enable = true;
            enableLuks = true;
            speedDisks = [ "/dev/nvme0n1" ];
          };
        };
        boot = {
          enable = true;
          loader = "limine";
        };
        security = {
          security.enable = true;
          ssh.enable = true;
        };
      };

      services.networking.tailscale.enable = true;
    };

    services.openssh.settings.PasswordAuthentication = false;
  };
}
```

______________________________________________________________________

## 🔄 Routine System Maintenance

| Command | Action | Description |
| :--- | :--- | :--- |
| `nrs` | `nh os switch --no-nom` | Rebuild and switch immediately |
| `nrb` | `nh os boot --no-nom` | Rebuild for next boot |
| `drs` | `nh darwin switch --no-nom` | Rebuild macOS Darwin profile |
| `nfu` | `nix flake update` | Update all flake lock inputs |
| `nfc` | `nix flake check` | Evaluate and validate entire flake |
| `nc` | `nh clean all` | Prune old generations, keep last 5 within 7 days |
| `seed` | `solar-seed` | Decrypt Age master key into RAM keyring |
| `unseed`| `solar-unseed` | Purge Age keys from RAM keyring |

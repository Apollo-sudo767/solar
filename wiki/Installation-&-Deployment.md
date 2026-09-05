# Installation & Deployment 🚀

Solar supports both automated remote provisioning (via `install.sh` and `nixos-anywhere`) and direct bare-metal installation from a standard NixOS Live USB.

______________________________________________________________________

## ⚡ Method 1: Automated Deployment via `install.sh`

Run the interactive wizard from any machine with Nix installed:

```bash
git clone https://github.com/Apollo-sudo767/solar.git
cd solar
./install.sh
```

### Interactive Steps:

1. **Host Selection**: Select target host (e.g. `thebe`, `ganymede`, `callisto`).
1. **Target IP**: IP address of the target machine (booted into a NixOS Minimal Live USB with `sshd` enabled).
1. **Build Mode**: Local compilation (recommended) or remote on-target build.
1. **Agenix Selection**: Select `2` (**DISABLED**) for standalone hosts without private secret access.
1. **User Password**: Set a password for initial login.

The installer handles disk partitioning via Disko, LUKS formatting, closure deployment, and bootloader configuration automatically.

______________________________________________________________________

## 🛠️ Method 2: Manual Installation from Live USB

On the target machine booted into the NixOS Live USB:

### 1. Partition & Format with Disko

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko \
  --flake "github:Apollo-sudo767/solar#<hostname>"
```

### 2. Install NixOS

```bash
sudo nixos-install --flake "github:Apollo-sudo767/solar#<hostname>"
```

### 3. Reboot

```bash
reboot
```

______________________________________________________________________

## 💿 Method 3: Dedicated Solar Live Installer ISO

Solar includes a custom live installer host (`modules/hosts/installer`) equipped with a graphical XFCE desktop, GParted, web browser, Wi-Fi configuration (`nmtui`), remote SSH authorization, and a built-in on-device installer tool (`solar-install`).

### 1. Build the Live ISO

From any machine with Nix and Linux build capability (or remote builder):

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting ISO image will be available at:
`./result/iso/solar-installer-*.iso`

### 2. Flash to USB Drive

```bash
sudo dd if=result/iso/solar-installer-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

*(Replace `/dev/sdX` with your USB drive block device).*

### 3. Boot & Install

The ISO boot menu provides two startup options:

1. **Graphical Desktop (XFCE)** (Default): Full desktop with browser, GParted, and terminal.
1. **Console / Text Mode**: Direct text console prompt with auto-login.

#### On-Device Installation

Launch the interactive installer directly from the desktop shortcut **"Install Solar"** or run in terminal:

```bash
sudo solar-install
```

The wizard will:

- Present all available hosts configured in the repository.
- Optionally generate a fresh `hardware-configuration.nix` for the detected hardware.
- Partition and format drives automatically via Disko.
- Install the NixOS system and configure initial user credentials.
- Prompt to reboot into your newly installed system.

______________________________________________________________________

## 🔄 Routine System Updates & Aliases

Once installed, use the built-in shell aliases:

```bash
nrs   # Rebuild and switch immediately via nh (nh os switch --no-nom)
nrb   # Rebuild for next boot (nh os boot --no-nom)
drs   # macOS Darwin rebuild (nh darwin switch --no-nom)
nfu   # Update all flake lock inputs (nix flake update)
nfc   # Check flake evaluation (nix flake check)
nc    # Clean profiles and generations keeping last 5 within 7d (nh clean all)
ncl   # Clean profiles (alias for nc)
nco   # Clean profiles and optimize/deduplicate Nix store
seed  # Unlock and seed Age master keys into RAM
unseed# Purge Age master keys from RAM
```

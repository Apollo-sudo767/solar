# Bare-Metal Installation Guide 🛠️

This guide covers deploying any host configuration from the **Solar** repository onto bare-metal hardware.

______________________________________________________________________

## ⚡ Method 1: Automated Installation via `install.sh` (Recommended)

From a workstation running Linux or macOS with Nix installed:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Apollo-sudo767/solar.git
   cd solar
   ```

1. **Execute the interactive installer:**

   ```bash
   ./install.sh
   ```

1. **Follow the interactive prompts:**

   - **Host selection**: Enter target hostname (e.g. `thebe`, `ganymede`, `callisto`).
   - **Target IP**: Enter IP address of target machine (booted into a [NixOS Minimal Live USB](https://nixos.org/download.html) with `sshd` enabled).
   - **Build mode**: `1` (Local compilation) or `2` (Remote compilation).
   - **Agenix Secret Management**: Select `2` (**DISABLED** for standalone hosts).
   - **User Password**: Enter a custom password or press Enter for default.

______________________________________________________________________

## 🛠️ Method 2: Manual Installation from NixOS Live USB

If installing directly on the target machine from a Live USB:

### Step 1: Verify Disk Device Names

```bash
lsblk
```

### Step 2: Partition and Format with Disko

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko \
  --flake "github:Apollo-sudo767/solar#<hostname>"
```

*(Enter the identical LUKS passphrase on all drives for multi-disk systems).*

### Step 3: Install NixOS

```bash
sudo nixos-install --flake "github:Apollo-sudo767/solar#<hostname>"
```

### Step 4: Reboot

```bash
reboot
```

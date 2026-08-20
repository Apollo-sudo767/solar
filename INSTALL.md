# Installation & Deployment Guide ☀️

This guide provides step-by-step instructions for deploying and installing any host configuration from the **Solar** repository onto bare-metal machines, including the Jupiter moon stack (**thebe**, **ganymede**, and **callisto**).

______________________________________________________________________

## 📋 Table of Contents

1. [Target Architecture & Disk Layout Overview](#target-architecture--disk-layout-overview)
1. [Prerequisites](#prerequisites)
1. [Method 1: Automated Installation via `install.sh` (Recommended)](#method-1-automated-installation-via-installsh-recommended)
1. [Method 2: Manual Installation from NixOS Live Installer](#method-2-manual-installation-from-nixos-live-installer)
1. [Host-Specific Installation Notes](#host-specific-installation-notes)
   - [Thebe (Intel Mac Mini)](#thebe-intel-mac-mini)
   - [Ganymede (Dedicated NAS)](#ganymede-dedicated-nas)
   - [Callisto (General Storage)](#callisto-general-storage)
1. [Post-Installation Configuration & Verification](#post-installation-configuration--verification)

______________________________________________________________________

## 🎯 Target Architecture & Disk Layout Overview

All three Jupiter moon hosts use **Disko**, **LUKS Encryption**, and **Btrfs** with `zstd` compression and `noatime`:

| Host | Role | Boot Drive(s) (`speedDisks`) | Data Drive(s) (`bulkDisks`) | Services |
| :--- | :--- | :--- | :--- | :--- |
| **`thebe`** | Intel Mac Mini | `/dev/sda` (or NVMe) | — | Intel graphics, Apple SMC, Limine bootloader |
| **`ganymede`** | Dedicated NAS | `/dev/nvme0n1` | `/dev/sda`, `/dev/sdb` | Samba (SMB3), NFS, Avahi mDNS, Btrfs Scrub |
| **`callisto`** | General Storage | `/dev/nvme0n1` | `/dev/sda` | Syncthing, Restic/Borg, Btrfs Scrub |

> [!NOTE]
> All three hosts are configured with `useSolarSecrets = false` and `useSecrets = false`, making them completely self-contained with zero dependencies on private secret repositories or `agenix`.

______________________________________________________________________

## ⚙️ Prerequisites

1. **Target Hardware**: Powered on and booted into a standard [NixOS Minimal Installer](https://nixos.org/download.html) (Live USB or PXE).
1. **Network Connection**: Target machine connected via Ethernet or Wi-Fi with an IP address assigned.
1. **SSH Access on Target**:
   ```bash
   # On the target live USB:
   sudo systemctl start sshd
   # Set a temporary password for root if needed:
   passwd
   # Check the IP address:
   ip a
   ```

______________________________________________________________________

## 🚀 Method 1: Automated Installation via `install.sh` (Recommended)

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

   - **Host selection**: Enter `thebe`, `ganymede`, or `callisto`.
   - **Target IP**: Enter the IP address of the target machine.
   - **Build mode**: Choose `1` (Build locally and copy to target) or `2` (Remote build on target).
   - **Agenix Secret Management**: Select `2` (**DISABLED** — bypasses agenix for self-contained hosts).
   - **SSH Host Key**: Choose `1` (Generate new SSH host key) or `3` (Skip).
   - **User Password**: Enter a custom password or press Enter for the default.

1. **Installation Execution**:
   The script will automatically invoke `disko` to partition and format the drives with LUKS and Btrfs, transfer the NixOS system closure, and set up the bootloader.

______________________________________________________________________

## 🛠️ Method 2: Manual Installation from NixOS Live Installer

If installing directly on the target machine from a NixOS Live USB:

### Step 1: Verify Disk Device Names

Check the disk layout on the machine:

```bash
lsblk
```

If your disk device paths differ from the defaults (e.g. `/dev/nvme0n1` vs `/dev/sda`), update `speedDisks` and `bulkDisks` in `modules/hosts/<hostname>/default.nix` accordingly.

### Step 2: Partition and Format with Disko

Run Disko directly to create the GPT table, EFI partition, LUKS containers, and Btrfs filesystems:

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko \
  --flake "github:Apollo-sudo767/solar#<hostname>"
```

*(You will be prompted to enter a passphrase for the LUKS encrypted volumes.)*

### Step 3: Install NixOS

```bash
sudo nixos-install --flake "github:Apollo-sudo767/solar#<hostname>"
```

### Step 4: Reboot

```bash
reboot
```

______________________________________________________________________

## 🖥️ Host-Specific Installation Notes

### Thebe (Intel Mac Mini)

- **Booting Live USB**: Hold the `Option` (or `Alt`) key immediately after powering on until the Apple boot menu appears, then select the EFI Boot USB drive.
- **Bootloader**: `thebe` uses `limine` with styled background graphics.
- **Thermal & Fan Control**: The `applesmc` kernel module is loaded automatically for thermal sensor monitoring.

### Ganymede (Dedicated NAS)

- **Disk Pool Setup**:
  - `speedDisks`: Fast NVMe/SSD drive for `/` and `/boot`.
  - `bulkDisks`: High-capacity HDDs partitioned and mounted as Btrfs at `/persist/bulk`.
- **Storage Share Path**: The default Samba & NFS shared directory is located at `/persist/bulk/storage`.
- **Permissions**: Create the storage directory after first boot:
  ```bash
  sudo mkdir -p /persist/bulk/storage
  sudo chown -R apollo:users /persist/bulk/storage
  sudo chmod -R 775 /persist/bulk/storage
  ```
- **Accessing Shares**:
  - **Samba (SMB3)**: `smb://ganymede.local/storage` or `\\<ganymede-ip>\storage`
  - **NFS**: `mount -t nfs <ganymede-ip>:/persist/bulk/storage /mnt/nas`

### Callisto (General Storage)

- **Disk Pool Setup**:
  - `speedDisks`: Fast primary drive for system files.
  - `bulkDisks`: Bulk storage drive mounted at `/persist/bulk`.
- **Syncthing Web GUI**:
  - Syncthing is bound to `127.0.0.1:8384` for security.
  - Access via SSH port forward:
    ```bash
    ssh -L 8384:127.0.0.1:8384 apollo@<callisto-ip>
    ```
    Then open `http://localhost:8384` in your browser.

______________________________________________________________________

## 🔒 Post-Installation Configuration & Verification

1. **Change User Password (if not set during install)**:

   ```bash
   passwd
   ```

1. **TPM2 LUKS Auto-Unlock (Optional)**:
   To automatically unlock encrypted drives via the machine's TPM 2.0 chip:

   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2  # (or your LUKS partition)
   ```

1. **Join Tailscale Mesh Network**:

   ```bash
   sudo tailscale up
   ```

1. **Verify Btrfs Status & Scrubbing**:

   ```bash
   sudo btrfs filesystem show
   sudo btrfs scrub status /
   ```

1. **Future System Rebuilds**:

   ```bash
   nrs   # (nixos-rebuild switch)
   nrb   # (nixos-rebuild boot)
   nfu   # (nix flake update)
   ```

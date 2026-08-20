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
1. [🔐 Setting Up LUKS Disk Encryption](#-setting-up-luks-disk-encryption)
   - [Crucial: Same Passphrase for Multi-Disk & Automated Reboots](#crucial-same-passphrase-for-multi-disk--automated-reboots)
   - [Adding Backup Recovery Keys](#adding-backup-recovery-keys)
1. [🔄 Easy Drive Swapping & Storage Pool Management](#-easy-drive-swapping--storage-pool-management)
   - [Using Persistent Drive Identifiers (`/dev/disk/by-id/`)](#using-persistent-drive-identifiers-devdiskby-id)
   - [Declarative Drive Replacement (via Disko)](#declarative-drive-replacement-via-disko)
   - [Live Zero-Downtime Drive Swapping (via Native Btrfs)](#live-zero-downtime-drive-swapping-via-native-btrfs)
1. [🛡️ Setting Up Native Secure Boot with Limine (`sbctl`)](#%EF%B8%8F-setting-up-native-secure-boot-with-limine-sbctl)
1. [🔑 Binding LUKS to Secure Boot via TPM 2.0 (Tamper-Proof Auto-Unlock)](#-binding-luks-to-secure-boot-via-tpm-20-tamper-proof-auto-unlock)
1. [Post-Installation Verification & Maintenance](#post-installation-verification--maintenance)

______________________________________________________________________

## 🎯 Target Architecture & Disk Layout Overview

All three Jupiter moon hosts use **Disko**, **LUKS Encryption**, and **Btrfs** with `zstd` compression and `noatime`:

| Host | Role | Boot Drive(s) (`speedDisks`) | Data Drive(s) (`bulkDisks`) | Bootloader & Services |
| :--- | :--- | :--- | :--- | :--- |
| **`thebe`** | Intel Mac Mini | `/dev/sda` (or NVMe) | — | Limine, Intel graphics, Apple SMC |
| **`ganymede`** | Dedicated NAS | `/dev/nvme0n1` | `/dev/sda`, `/dev/sdb` | Limine, Samba (SMB3), NFS, Avahi mDNS, Btrfs Scrub |
| **`callisto`** | General Storage | `/dev/nvme0n1` | `/dev/sda` | Limine, Syncthing, Restic/Borg, Btrfs Scrub |

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
   # Set a temporary password for root:
   passwd
   # Check the target IP address:
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
   - **User Password**: Enter a custom password or press Enter for default.

1. **Installation Execution**:
   The script will automatically invoke `disko` to partition and format the drives with LUKS and Btrfs, transfer the NixOS system closure, and configure the Limine bootloader.

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

*(You will be prompted to enter a passphrase for each LUKS encrypted volume.)*

> [!IMPORTANT]
> When Disko prompts for passphrases on multi-drive systems (`ganymede` / `callisto`), **set the EXACT same passphrase on all disks**. See the section below for details.

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

## 🔐 Setting Up LUKS Disk Encryption

Disko automatically configures **LUKS2 encryption** on all `speedDisks` and `bulkDisks` when `enableLuks = true` (default on `thebe`, `ganymede`, and `callisto`).

### Crucial: Same Passphrase for Multi-Disk & Automated Reboots

> [!IMPORTANT]
> **ALWAYS set the same LUKS passphrase across all encrypted drives in a multi-disk machine.**
>
> **Why this is required:**
>
> 1. **Single-Prompt Booting:** During early boot (`initrd`), `systemd-cryptsetup` caches the passphrase entered for the root disk and automatically tries it against all remaining encrypted disks. If all disks share the same passphrase, you only type your password **once** on boot rather than once per drive.
> 1. **Automating Reboots & Remote Restarts:** When automating reboots or deploying remotely, mismatched passphrases will cause the boot sequence to stall waiting for secondary disk passwords.
> 1. **TPM 2.0 Fallback:** If TPM2 auto-unlock ever requires manual fallback (e.g. after a firmware update), typing the passphrase once unlocks the entire storage array simultaneously.

If you ever need to synchronize or add the same passphrase across existing drives:

```bash
# Add the primary passphrase to your bulk disk(s):
sudo cryptsetup luksAddKey /dev/sda1
sudo cryptsetup luksAddKey /dev/sdb1
```

### Adding Backup Recovery Keys

After booting into the installed system, you can add a secondary recovery passphrase to key slot 1:

```bash
# Identify your encrypted partition (e.g., /dev/nvme0n1p2 or /dev/sda2)
lsblk -f

# Add a secondary recovery passphrase:
sudo cryptsetup luksAddKey /dev/nvme0n1p2
```

### Inspecting LUKS Key Slots

You can verify active key slots and encryption parameters at any time:

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2
```

______________________________________________________________________

## 🔄 Easy Drive Swapping & Storage Pool Management

The Solar Disko architecture is hardware-aware and designed for **seamless drive replacement, disk swaps, and storage expansion**.

### Using Persistent Drive Identifiers (`/dev/disk/by-id/`)

Linux device names like `/dev/sda` and `/dev/sdb` can occasionally change order across reboots when hardware cables or controllers are reordered. To ensure drive swaps are 100% deterministic, you can specify drives by their persistent hardware ID in your host configuration:

```bash
# List all disks by model and serial number:
ls -la /dev/disk/by-id/
```

In `modules/hosts/<hostname>/default.nix`:

```nix
system.disko = {
  enable = true;
  enableLuks = true;
  speedDisks = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0R123456" ];
  bulkDisks = [
    "/dev/disk/by-id/ata-WDC_WD40EFRX-68N32N0_WD-WCC7K1234567"
    "/dev/disk/by-id/ata-WDC_WD40EFRX-68N32N0_WD-WCC7K7654321"
  ];
};
```

*Disko automatically sanitizes device paths and configures the corresponding mapper names.*

______________________________________________________________________

### Declarative Drive Replacement (via Disko)

When permanently replacing a failed drive or upgrading a disk:

1. **Power down and physically swap the drive** (or connect the replacement disk).
1. **Update the device list** in `modules/hosts/<hostname>/default.nix` with the new disk path / ID.
1. **Partition & format the new drive into the pool with Disko:**
   ```bash
   sudo nix --extra-experimental-features "nix-command flakes" \
     run github:nix-community/disko -- \
     --mode disko \
     --flake .#<hostname>
   ```
   *(Ensure you enter the same LUKS passphrase as the rest of the pool).*
1. **Re-enroll TPM 2.0 auto-unlock on the new drive partition:**
   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 <new_luks_partition>
   ```

______________________________________________________________________

### Live Zero-Downtime Drive Swapping (via Native Btrfs)

For active NAS and storage servers (**ganymede** and **callisto**), Btrfs allows you to hot-swap or replace drives **live without unmounting shares or taking the storage offline**:

#### 1. Live Replacing a Drive in the Btrfs Pool:

```bash
# 1. Format and encrypt the replacement drive with the same passphrase:
sudo cryptsetup luksFormat --type luks2 /dev/sdc1
sudo cryptsetup open /dev/sdc1 crypted-bulk-new

# 2. Live stream and mirror data from old drive to new drive:
sudo btrfs replace start /dev/mapper/crypted-bulk-sda /dev/mapper/crypted-bulk-new /persist/bulk

# 3. Check progress:
sudo btrfs replace status /persist/bulk
```

*Once replacement completes, the old drive is automatically removed from the pool and can be unplugged.*

#### 2. Adding a New Drive to Expand Storage:

```bash
# Format and open LUKS on the new drive:
sudo cryptsetup luksFormat --type luks2 /dev/sdd1
sudo cryptsetup open /dev/sdd1 crypted-bulk-extra

# Add the new device into the bulk storage pool:
sudo btrfs device add /dev/mapper/crypted-bulk-extra /persist/bulk

# Rebalance data across all drives (optional, runs in background):
sudo btrfs balance start /persist/bulk
```

______________________________________________________________________

## 🛡️ Setting Up Native Secure Boot with Limine (`sbctl`)

Secure Boot ensures that only cryptographically signed kernels and EFI bootloaders can execute on the hardware, preventing evil-maid attacks and boot-level tampering.

### Step 1: Put UEFI Firmware into Setup Mode

1. Reboot the machine and enter your motherboard's UEFI/BIOS settings (usually `Del`, `F2`, or `F12`).
1. Navigate to the **Secure Boot** settings.
1. Select **Clear Secure Boot Keys** or **Enter Setup Mode** (this puts the firmware in "Setup Mode" allowing custom key enrollment).
1. Save and reboot into NixOS.

### Step 2: Generate Custom Secure Boot Keys

In NixOS, run `sbctl` to generate your private platform keys (stored securely in `/var/lib/sbctl`):

```bash
# Verify the system is in Setup Mode
sudo sbctl status

# Create custom platform keys
sudo sbctl create-keys
```

### Step 3: Enroll Keys into UEFI Firmware

Enroll your custom keys along with Microsoft OEM certificates (necessary to prevent bricking option ROMs on GPUs and expansion cards):

```bash
sudo sbctl enroll-keys --microsoft
```

### Step 4: Sign Bootloader and Kernels

Sign the Limine EFI bootloader and kernel binaries:

```bash
# Sign all EFI binaries in /boot
sudo find /boot -type f -name "*.efi" -exec sbctl sign -s {} +

# Sign all kernel binaries
sudo find /boot -type f \( -name "vmlinuz*" -o -name "bzImage*" \) -exec sbctl sign -s {} +
```

### Step 5: Enable Automated Secure Boot Signing in Host Config

In `modules/hosts/<hostname>/default.nix`, enable automated signing on future rebuilds:

```nix
myFeatures.core.boot.secureBoot.enable = true;
```

Now, whenever `nixos-rebuild` builds a new generation or kernel, Limine and the kernel will be signed automatically!

______________________________________________________________________

## 🔑 Binding LUKS to Secure Boot via TPM 2.0 (Tamper-Proof Auto-Unlock)

By pairing **LUKS encryption** with **Secure Boot** through the **TPM 2.0** chip, the system can automatically unlock encrypted drives on boot **without prompting for a password**—while remaining fully secure against tampering.

### How it Works:

- We bind the LUKS encryption key to TPM registers **PCR 0** (core motherboard firmware) and **PCR 7** (Secure Boot state & signed certificate database).
- **Normal Boot:** Secure Boot verifies the signed Limine bootloader and signed kernel $\\rightarrow$ PCR 7 matches $\\rightarrow$ TPM releases LUKS key $\\rightarrow$ System boots seamlessly without password prompts.
- **Tampered Boot:** If an attacker modifies the kernel, disables Secure Boot, boots a live USB, or moves the drive to another machine $\\rightarrow$ PCR 7 measurement changes $\\rightarrow$ TPM **refuses** to release the key $\\rightarrow$ System demands the manual LUKS recovery passphrase.

### Enrolling the TPM 2.0 Key:

Run `systemd-cryptenroll` on each encrypted disk partition:

```bash
# 1. Primary OS / Speed Drive:
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2

# 2. Bulk Storage Drives (e.g. on NAS / Storage hosts):
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/sda1
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/sdb1
```

### Verifying TPM 2.0 Enrollment:

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2
```

*(You will see a `systemd-tpm2` token listed alongside your manual passphrase keyslot.)*

> [!TIP]
> If a future motherboard firmware update changes PCR 0 and causes TPM unlock to fail, simply enter your manual recovery passphrase at boot, then re-enroll the TPM with `systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2`.

______________________________________________________________________

## 🔄 Post-Installation Verification & Maintenance

1. **Verify TPM Auto-Unlock:**
   Reboot the machine to confirm that LUKS unlocks automatically via TPM 2.0 when Secure Boot is active:

   ```bash
   sudo reboot
   ```

1. **Verify Secure Boot Status:**

   ```bash
   sudo sbctl status
   # Should output: Secure Boot: Enabled (user keys enrolled)
   ```

1. **Join Tailscale Mesh Network:**

   ```bash
   sudo tailscale up
   ```

1. **Verify Btrfs Status & Scrubbing:**

   ```bash
   sudo btrfs filesystem show
   sudo btrfs scrub status /
   ```

1. **Routine Maintenance & Upgrades:**

   ```bash
   nrs   # Rebuild and switch (nixos-rebuild switch)
   nrb   # Rebuild for next boot (nixos-rebuild boot)
   nfu   # Update flake inputs (nix flake update)
   ```

# Installation & Deployment Guide ☀️

This guide provides step-by-step instructions for deploying and installing any host configuration from the **Solar** repository onto bare-metal machines, including personal workstations, portable laptops, and the Pluto cluster nodes (**pluto**, **styx**, and **hydra**).

______________________________________________________________________

## 📋 Table of Contents

1. [Target Architecture & Disk Layout Overview](#target-architecture--disk-layout-overview)
1. [Prerequisites](#prerequisites)
1. [Method 1: Solar Live Installer Image (`solar-install`)](#method-1-solar-live-installer-image-solar-install)
1. [Method 2: Manual Installation from NixOS Live Installer via Disko](#method-2-manual-installation-from-nixos-live-installer-via-disko)
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

## 🚀 Method 1: Solar Live Installer Image (`solar-install`)

Solar includes a custom, fully-equipped Live Installer ISO configuration (`modules/hosts/installer/default.nix`) with automatic network configuration, Disko, GParted, and the interactive `solar-install` tool built-in.

### 1. Build the Solar Live Installer ISO

From a workstation running Linux or macOS with Nix installed:

```bash
cd ~/src/solar
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting bootable `.iso` will be in `./result/iso/`.

### 2. Flash to USB Drive

```bash
# Identify your USB drive (e.g. /dev/sdX):
lsblk

# Write ISO directly:
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

### 3. Boot Target Hardware & Install

1. Boot the target machine from the USB drive.
1. In the terminal (or via SSH as `nixos` / `root`), run:
   ```bash
   sudo solar-install
   ```
1. Follow the interactive installer wizard:
   - **Repository Source**: Choose to fetch the latest `solar` flake from GitHub (default), use a bundled offline copy (`/home/nixos/solar`), or a custom path.
   - **Host Configuration**: Select the target machine configuration to install (e.g. `hydra`, `styx`, `thebe`, `ganymede`).
   - **Secrets Management & Host Key Provisioning**: If installing a host that uses `solar-secrets` (such as Pluto cluster nodes), the installer locks `solar-secrets` into `flake.lock` for offline evaluation. Host private keys are kept strictly on `mars` (`~/.ssh/hosts/<hostname>/`) and provisioned out-of-band via interactive paste or `scp` from `mars`.
   - **User Password**: Enter an initial password for user accounts and root (mandatory non-empty password to prevent default credential risks).
   - **Disko Partitioning & Formatting**: Disko wipes the target disk, creates partition tables, EFI boot partitions, and Btrfs subvolumes (`/root`, `/nix`, `/persist`), mounting them cleanly to `/mnt`.
   - **System Build & Install**: NixOS is built and installed to `/mnt` via `nixos-install`.
   - **User Credentials Finalization**: Initial password hashes are written to `/mnt/etc/shadow` and `/mnt/persist/etc/user-password`.
   - **Reboot**: Select `y` to reboot directly into your newly installed Solar system.

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

Run Disko directly to wipe the target disk, create the GPT table, EFI partition, and format Btrfs subvolumes (`/root`, `/nix`, `/persist`):

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --yes-wipe-all-disks \
  --flake "github:Apollo-sudo767/solar#<hostname>"
```

*(If prompted for LUKS encryption passphrases on encrypted nodes, enter your passphrase).*

> [!IMPORTANT]
> When Disko prompts for passphrases on multi-drive systems (`ganymede` / `callisto`), **set the EXACT same passphrase on all disks**. See the section below for details.

### Step 3 (For Agenix Secret Hosts): Provision Host SSH Key

For hosts using private secrets (`hydra`, `pluto`, `styx`):

1. **Ensure Persistent SSH Directory Exists**:

   ```bash
   sudo mkdir -p /mnt/persist/etc/ssh /mnt/etc/ssh
   sudo chmod 755 /mnt/persist/etc/ssh /mnt/etc/ssh
   ```

1. **Provision Host Key**:

   - **Option A (Direct Transfer from Workstation ~/.ssh/hosts/<hostname>/)**:
     Host private keys are stored securely on `mars` (`~/.ssh/hosts/<hostname>/`) and not in Git:
     ```bash
     # From mars:
     scp ~/.ssh/hosts/<hostname>/ssh_host_ed25519_key* root@<installer-ip>:/mnt/persist/etc/ssh/

     # On the installer:
     sudo cp /mnt/persist/etc/ssh/ssh_host_ed25519_key* /mnt/etc/ssh/
     sudo chmod 600 /mnt/persist/etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key
     ```
   - **Option B (Transfer via Laptop / MacBook Intermediary)**:
     When performing field deployments or on-site installations using a laptop/MacBook:
     ```bash
     # 1. Copy host key from Mars to MacBook (run from Mars or MacBook):
     # From Mars:
     ssh apollo@macbook-pro "mkdir -p ~/.ssh/hosts"
     scp -r ~/.ssh/hosts/<hostname> apollo@macbook-pro:~/.ssh/hosts/
     # (Or pull from MacBook):
     mkdir -p ~/.ssh/hosts/<hostname>
     scp -r apollo@mars:~/.ssh/hosts/<hostname>/ ~/.ssh/hosts/<hostname>/

     # 2. Push key from MacBook to target installer machine:
     scp ~/.ssh/hosts/<hostname>/ssh_host_ed25519_key* root@<installer-ip>:/mnt/persist/etc/ssh/
     # Or if Disko hasn't partitioned/mounted /mnt yet, stage in /home/nixos/:
     scp ~/.ssh/hosts/<hostname>/ssh_host_ed25519_key* nixos@<installer-ip>:/home/nixos/
     ```
   - **Option C (Generate new key on installer)**:
     ```bash
     sudo ssh-keygen -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key -N "" -C "root@<hostname>"
     sudo cp /mnt/persist/etc/ssh/ssh_host_ed25519_key* /mnt/etc/ssh/
     sudo chmod 600 /mnt/persist/etc/ssh/ssh_host_ed25519_key /mnt/etc/ssh/ssh_host_ed25519_key
     cat /mnt/persist/etc/ssh/ssh_host_ed25519_key.pub
     ```
     *(Add this public key to `solar-secrets/hosts/<hostname>.pub`, rekey secrets with `s-rekey` on your workstation, and commit/push before installing).*

### Step 4: Rekey Secrets on Workstation (If Host Key Changed)

On your management workstation (`mars`), rekey secrets for the target host:

```bash
s-rekey
```

*(Or execute the full command as a single line:)*

```bash
AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/solar-secrets nix run --override-input solar-secrets path:$HOME/src/solar-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-rekey && git -C $HOME/src/solar add rekeyed
```

### Step 5: Install NixOS Closure

```bash
sudo nixos-install --flake "github:Apollo-sudo767/solar#<hostname>" --no-root-password
```

### Step 6: Reboot

```bash
sudo reboot
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

1. Reboot the machine and enter your motherboard's UEFI/BIOS settings (press `F1` on Lenovo ThinkCentres, or `Del` / `F2` on other motherboards).
1. Navigate to the **Security → Secure Boot** settings.
1. Select **Clear Secure Boot Keys** or **Enter Setup Mode** (this sets the firmware to "Setup Mode: Enabled", allowing custom key enrollment).
1. Ensure **Secure Boot** is set to **Disabled** for now during initial setup.
1. Save and reboot into NixOS.

### Step 2: Ensure Key Persistence & Generate Platform Keys

Because Solar uses an ephemeral root filesystem on tmpfs, `/var/lib/sbctl` must be bind-mounted to persistent storage before creating keys:

```bash
# Ensure persistent directory exists and bind mount it
sudo mkdir -p -m 700 /persist/var/lib/sbctl /var/lib/sbctl
sudo mount --bind /persist/var/lib/sbctl /var/lib/sbctl

# Verify the system is in Setup Mode
sudo sbctl status

# Create custom platform keys
sudo sbctl create-keys
```

### Step 3: Enroll Keys into UEFI Firmware

Enroll your custom keys along with Microsoft OEM certificates (necessary to prevent bricking Option ROMs on GPUs and expansion cards):

```bash
sudo sbctl enroll-keys --microsoft
```

### Step 4: Sign Bootloaders and Kernels

Sign both the primary Limine EFI binary, the universal UEFI fallback binary (`/boot/EFI/BOOT/BOOTX64.EFI`), and the active kernel:

```bash
# 1. Mirror and sign Limine bootloaders
sudo mkdir -p /boot/EFI/BOOT
sudo cp -u /boot/efi/limine/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI

sudo sbctl sign -s /boot/efi/limine/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI

# 2. Sign all installed kernels
sudo sh -c 'sbctl sign -s /boot/limine/kernels/*bzImage*'

# 3. Verify all signatures are valid (all green checkmarks)
sudo sbctl verify
```

### Step 5: Enable Automated Secure Boot Signing in Host Config

Now that your platform keys exist in `/var/lib/sbctl`, enable automated signing on future rebuilds in `modules/hosts/<hostname>/default.nix`:

```nix
myFeatures.core.boot.secureBoot.enable = true;
```

Switch the configuration to lock in automated signing and persistent mounting:

```bash
sudo nixos-rebuild switch
```

______________________________________________________________________

## 🔑 Binding LUKS to Secure Boot via TPM 2.0 (Tamper-Proof Auto-Unlock)

By pairing **LUKS encryption** with **Secure Boot** through the **TPM 2.0** chip, the system automatically unlocks encrypted drives on boot **without prompting for a password**—while remaining fully secure against tampering.

> [!CAUTION]
> **CRITICAL ORDER OF OPERATIONS: DO NOT ENROLL TPM BEFORE ENABLING SECURE BOOT!**
>
> TPM register **PCR 7** measures the active Secure Boot state and certificate policy:
>
> 1. If you run `systemd-cryptenroll` while Secure Boot is **Disabled**, the TPM seals your disk encryption key to the *disabled* state.
> 1. As soon as you turn on Secure Boot in the BIOS, PCR 7 changes completely.
> 1. The TPM will detect the PCR mismatch and **refuse to unlock the disk**, causing a boot halt or prompting for the manual passphrase.
>
> **You must ALWAYS enable Secure Boot in the BIOS first, boot into NixOS with Secure Boot active, and ONLY THEN run `systemd-cryptenroll`.**

### Step 1: Turn on Secure Boot in BIOS

1. Reboot the machine (`sudo reboot`) and press **F1** (or `Del` / `F2`) to enter BIOS Setup.
1. Navigate to **Security → Secure Boot**.
1. Toggle **Secure Boot** to **Enabled**.
1. *(On Lenovo ThinkCentres)*: Ensure **Allow Microsoft 3rd Party UEFI CA** is set to **Enabled**.
1. Press **F10** to save changes and restart.

### Step 2: Boot into NixOS with Secure Boot Active

1. Styx will boot directly into Limine under active Secure Boot.
1. Enter your manual LUKS disk passphrase on the physical keyboard/screen to unlock the drive this one time.
1. Log in to your user account.

### Step 3: Enroll the TPM 2.0 Key

Now that the system is running under active Secure Boot, seal the LUKS key to your hardware's exact Secure Boot measurements:

```bash
# 1. Primary OS / Speed Drive (e.g. Styx / Hydra NVMe):
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2

# 2. Bulk Storage Drives (if present on NAS / Storage hosts):
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/sda1
```

### Step 4: Verify TPM 2.0 Enrollment

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2
```

*(You will see a `systemd-tpm2` token listed in keyslot 1 alongside your manual password keyslot 0).*

> [!TIP]
> If a future motherboard firmware update or BIOS update changes PCR 0/7 and causes TPM unlock to fail, simply enter your manual recovery passphrase at boot, then re-enroll the TPM with:
>
> ```bash
> sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2
> sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
> ```

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

1. **Verify Pluto Cluster Health (for K3s Nodes):**
   On cluster nodes (`pluto`, `hydra`, `styx`), verify K3s and pods:

   ```bash
   kubectl get nodes -o wide
   kubectl get pods -A
   # Or run the automated health check:
   # see pluto-cluster/TRANSFER.md Step 5.4
   ```

1. **Routine Maintenance & Upgrades:**

   ```bash
   nrs   # Rebuild and switch (nixos-rebuild switch)
   nrb   # Rebuild for next boot (nixos-rebuild boot)
   nfu   # Update flake inputs (nix flake update)
   ```

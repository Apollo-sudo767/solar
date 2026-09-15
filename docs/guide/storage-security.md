# Storage, Disko & Security 💾

Solar incorporates zero-compromise security and declarative storage partitioning across all nodes.

______________________________________________________________________

## 💾 Universal Disko Storage Engine

The Disko configuration module automatically detects drive topologies and configures partitions, filesystems, and encryption without custom per-machine disk recipes:

```nix
myFeatures.core.system.disko = {
  enable = true;
  enableLuks = true;               # Full-disk LUKS2 encryption
  speedDisks = [ "/dev/nvme0n1" ]; # High-speed OS drive
  bulkDisks = [                    # Multi-disk bulk storage pool
    "/dev/sda"
    "/dev/sdb"
  ];
};
```

______________________________________________________________________

## 📂 Storage Modes

### 1. Wipe-on-Boot Mode (`usePersistence = true`)

*Applied on security-hardened personal workstations, laptops, and stateless cluster nodes (`mars`, `mercury`, `pluto`, `styx`, `hydra`, `sol`).*

- **Root Filesystem (`/`)**: 4GB in-memory `tmpfs` completely wiped on every reboot.
- **Nix Store**: High-speed Btrfs `/nix` subvolume.
- **Preserved State**: Stateful user and system directories persist onto `/persist`:
  - `/persist/home/apollo`
  - `/persist/etc/nixos`
  - `/persist/var/log`
- **Zero Rot**: Leftover caches, test configs, and malicious persistence mechanisms vanish upon reboot.

### 2. Standard Mode (`usePersistence = false`)

*Applied on general servers, compact nodes, and gaming rigs (`thebe`, `venus`, `elara`, `amalthea`, `io`).*

- Standard root Btrfs filesystem mounted at `/` with `compress=zstd` and `noatime`.
- Bulk storage drives mounted at `/persist/bulk` with `neededForBoot = true`.

______________________________________________________________________

## 📊 Fleet Storage Matrix

| Host | Preservation Mode | LUKS2 Encryption | Primary Disks | Bulk Storage | Filesystems Mounted |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`sol`** | **YES** (`tmpfs` root) | **NO** | 1x NVMe | 2x HDD (ZFS Mirror `tank`) | `/` (`tmpfs`), `/boot`, `/nix`, `/persist`, `/tank` (NFS & Samba) |
| **`mars`** | **YES** (`tmpfs` root) | **YES** | 2x NVMe | 2x HDD | `/` (`tmpfs`), `/boot`, `/nix`, `/persist`, `/persist/bulk` |
| **`mercury`** | **YES** (`tmpfs` root) | **YES** | 1x NVMe | None | `/` (`tmpfs`), `/boot`, `/nix`, `/persist` |
| **`pluto`** | **YES** (`tmpfs` root) | **NO** | 1x NVMe | None (Stateless K3s) | `/` (`tmpfs`), `/boot`, `/nix`, `/persist` |
| **`styx`** | **YES** (`tmpfs` root) | **NO** | 1x NVMe | None (Stateless K3s) | `/` (`tmpfs`), `/boot`, `/nix`, `/persist` |
| **`hydra`** | **YES** (`tmpfs` root) | **NO** | 1x NVMe | None (Stateless K3s) | `/` (`tmpfs`), `/boot`, `/nix`, `/persist` |
| **`thebe`** | **NO** (Standard) | **YES** | 1x SSD/NVMe | None | `/`, `/boot` |
| **`venus`** | **NO** (Standard) | **NO** | 1x NVMe | None | `/`, `/boot` |
| **`elara`** | **NO** (Standard) | **NO** | 1x SSD | None | `/`, `/boot` |
| **`amalthea`**| **NO** (Standard) | **NO** | 1x eMMC/SSD | None | `/`, `/boot`, `/mnt/games` |
| **`io`** | **NO** (Standard) | **NO** | 1x SSD | None | `/`, `/boot` |

::: info Deprecated Storage Hosts
Legacy storage hosts **`ganymede`** (Dedicated NAS) and **`callisto`** (Storage & Backup) have been retired in favor of **`sol`** (Central ZFS NAS) and the **Pluto Cluster**. **`thebe`** remains actively maintained as a standalone compact server.
:::

______________________________________________________________________

## 🛡️ Security & Hardening Architecture

### 1. Limine Secure Boot

All UEFI hosts boot via Limine with automatic Secure Boot validation using enrolled keys:

```nix
myFeatures.core.boot = {
  loader = "limine";
  secureBoot.enable = true;
};
```

### 2. TPM 2.0 PCR 0+7 Auto-Unlock

For LUKS encrypted machines, decryption keys are bound to motherboard firmware state (PCR 0) and Secure Boot signature status (PCR 7):

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
```

- **Authorized Boot**: Secure Boot verifies the kernel signature $\\rightarrow$ TPM releases key $\\rightarrow$ boots seamlessly without password prompts.
- **Tampered Boot**: If firmware is altered or unverified kernels are booted $\\rightarrow$ TPM refuses key $\\rightarrow$ prompts for manual recovery passphrase.

### 3. Agenix Secrets Management & Zero-Trust Host Keys

Solar enforces a strict asymmetric encryption model with **zero private keys in Git**:

- **Secrets Storage**: Encrypted Age secrets (`*.age`) live in `solar-secrets/secrets/` and rekeyed outputs in `solar/rekeyed/`.
- **Public Keys**: Only public keys (`hosts/<hostname>.pub`) are tracked in `solar-secrets/hosts/`, used by `agenix-rekey` to encrypt secrets.
- **Private Host Key Isolation**:
  - Host private keys (`ssh_host_ed25519_key`) are **strictly prohibited** from Git repositories.
  - Master workstation copies reside exclusively on `mars` at `~/.ssh/hosts/<hostname>/ssh_host_ed25519_key` with strict `0600` permissions.
- **Out-of-Band Provisioning**:
  - During installation via `solar-install`, private keys are securely transferred out-of-band (via interactive terminal paste or direct `scp` from `mars` to `/mnt/persist/etc/ssh/`).
  - When combined with Solar's ephemeral root, host keys persist under `/persist/etc/ssh/` across reboots while the root filesystem (`/`) remains 100% immutable.
- **Runtime Decryption**: Unlocked into ramdisk at `/run/agenix/<name>` on boot, accessible only to authorized services.

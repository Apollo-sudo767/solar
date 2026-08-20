# Universal Hardware-Aware Disko 💾

All Linux storage in Solar is managed by the **Universal Hardware-Aware Disko Module** (`modules/core/system/disko.nix`).

______________________________________________________________________

## ⚙️ Declarative Storage Specification

Instead of creating separate partitioning scripts for each computer, Disko provisions partition layouts dynamically based on two declarative list options:

```nix
# Inside modules/hosts/<hostname>/default.nix
myFeatures.core.system.disko = {
  enable = true;
  enableLuks = true;
  speedDisks = [ "/dev/nvme0n1" ];
  bulkDisks = [ "/dev/sda" "/dev/sdb" ];
};
```

______________________________________________________________________

## 📂 Preservation vs. Non-Preservation Modes

Universal Disko adapts automatically depending on whether wipe-on-boot preservation is enabled:

### 1. Standard Mode (`usePersistence = false`)

*Used by: `thebe`, `ganymede`, `callisto`, `elara`, `amalthea`*

- **Boot Partition:** 2GB EFI System Partition (`vfat`, `umask=0077`) at `/boot`.
- **Root Filesystem:** Formatted directly as Btrfs mounted at `/` with `compress=zstd` and `noatime`.
- **Multi-Disk Speed Pool:** Additional drives in `speedDisks` join the `speed` Btrfs multi-device pool under `/`.
- **Bulk Storage Pool (`bulkDisks`):** Formatted as Btrfs (`-L bulk`) and mounted at `/persist/bulk` with `neededForBoot = true` to guarantee early availability for services like Samba, NFS, and Syncthing.
- **LUKS Encryption:** Optional full-disk encryption (`enableLuks = true`) with TRIM discards enabled across all disks.

### 2. Wipe-on-Boot Mode (`usePersistence = true`)

*Used by: `mars`, `mercury`*

- **Root Filesystem (`/`):** 4GB in-memory `tmpfs` wiped completely on every reboot.
- **Boot Partition:** 2GB EFI System Partition at `/boot`.
- **Btrfs Subvolumes:**
  - `/root` $\\rightarrow$ `/mnt-root`
  - `/nix` $\\rightarrow$ `/nix` (Nix store)
  - `/persist` $\\rightarrow$ `/persist` (Stateful persistent files)
  - `/persist/bulk` $\\rightarrow$ `/persist/bulk` (Bulk storage pool, mounted with `neededForBoot = true`).

______________________________________________________________________

## 📊 Fleet Storage Matrix

| Host | Preservation Mode | LUKS2 Encryption | Speed Disks | Bulk Disks | Mounted FileSystems |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`mars`** | **YES** (`tmpfs` root) | **YES** | 2x NVMe | 2x HDD | `/` (`tmpfs`), `/boot`, `/mnt-root`, `/nix`, `/persist`, `/persist/bulk` |
| **`mercury`** | **YES** (`tmpfs` root) | **YES** | 1x NVMe | None | `/` (`tmpfs`), `/boot`, `/mnt-root`, `/nix`, `/persist` |
| **`thebe`** | **NO** (Standard) | **YES** | 1x SSD/NVMe | None | `/`, `/boot` |
| **`ganymede`** | **NO** (Standard) | **YES** | 1x NVMe | 2x HDD | `/`, `/boot`, `/persist/bulk` |
| **`callisto`** | **NO** (Standard) | **YES** | 1x NVMe | 1x HDD | `/`, `/boot`, `/persist/bulk` |
| **`elara`** | **NO** (Standard) | **NO** | 1x SSD | None | `/`, `/boot` |
| **`amalthea`**| **NO** (Standard) | **NO** | 1x eMMC/SSD | None | `/`, `/boot`, `/mnt/games` |

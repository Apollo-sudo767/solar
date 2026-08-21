# Storage & Disko Architecture 💾

All Linux storage in Solar is managed by the **Universal Hardware-Aware Disko Module** (`modules/core/system/disko.nix`).

______________________________________________________________________

## ⚙️ How Universal Disko Works

Instead of creating separate partitioning scripts for each computer, Disko provisions partition layouts dynamically based on two declarative list options:

- **`speedDisks`**: Fast NVMe/SSD drives for OS, boot (`/boot`), and cache.
- **`bulkDisks`**: High-capacity secondary SSDs or HDDs provisioned and mounted at `/persist/bulk`.

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

*Ideal for servers, NAS, storage nodes, and general workstations (`thebe`, `ganymede`, `callisto`, `elara`, `amalthea`).*

- **Boot Partition:** 2GB EFI System Partition (`vfat`, `umask=0077`) at `/boot`.
- **Root Filesystem:** Formatted directly as Btrfs mounted at `/` with `compress=zstd` and `noatime`.
- **Multi-Disk Speed Pool:** Additional drives in `speedDisks` join the `speed` Btrfs multi-device pool under `/`.
- **Bulk Storage Pool (`bulkDisks`):** Formatted as Btrfs (`-L bulk`) and mounted at `/persist/bulk` with `neededForBoot = true` to guarantee early availability for services like Samba, NFS, and Syncthing.
- **LUKS Encryption:** Optional full-disk encryption (`enableLuks = true`) with TRIM discards enabled across all disks.

### 2. Wipe-on-Boot Mode (`usePersistence = true`)

*Ideal for security-hardened personal workstations and laptops (`mars`, `mercury`).*

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

______________________________________________________________________

## 🔄 Easy Drive Swapping & Expansion

### 1. Using Persistent Hardware IDs (`/dev/disk/by-id/`)

To prevent device letters (`/dev/sda` vs `/dev/sdb`) from swapping across reboots, specify persistent device identifiers in your host config:

```nix
speedDisks = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0R123456" ];
bulkDisks = [
  "/dev/disk/by-id/ata-WDC_WD40EFRX-68N32N0_WD-WCC7K1234567"
  "/dev/disk/by-id/ata-WDC_WD40EFRX-68N32N0_WD-WCC7K7654321"
];
```

*Disko automatically sanitizes device paths and configures the corresponding mapper names.*

### 2. Live Zero-Downtime Drive Replacement (Btrfs)

For live NAS or storage servers without taking shares offline:

```bash
# 1. Format & open LUKS container on new drive with the same passphrase:
sudo cryptsetup luksFormat --type luks2 /dev/sdc1
sudo cryptsetup open /dev/sdc1 crypted-bulk-new

# 2. Live-stream data from old drive to new drive without unmounting:
sudo btrfs replace start /dev/mapper/crypted-bulk-sda /dev/mapper/crypted-bulk-new /persist/bulk

# 3. Monitor status:
sudo btrfs replace status /persist/bulk
```

### 3. Adding New Drives to Expand Pools

```bash
sudo cryptsetup luksFormat --type luks2 /dev/sdd1
sudo cryptsetup open /dev/sdd1 crypted-bulk-extra
sudo btrfs device add /dev/mapper/crypted-bulk-extra /persist/bulk
```

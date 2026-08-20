# Storage & Disko Architecture 💾

All Linux storage in Solar is managed by the **Universal Hardware-Aware Disko Module** (`modules/core/system/disko.nix`).

______________________________________________________________________

## ⚙️ How Universal Disko Works

Instead of creating separate partitioning scripts for each computer, Disko provisions partition layouts dynamically based on two declarative list options:

- **`speedDisks`**: High-speed NVMe/SSD drives for OS, boot (`/boot`), and cache.
- **`bulkDisks`**: Secondary SSDs or HDDs provisioned and mounted at `/persist/bulk`.

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

## 📂 Filesystem Layout

### 1. Standard Mode (`usePersistence = false`)

- `/boot`: 2GB EFI System Partition (`vfat`, `umask=0077`).
- `/`: Primary Btrfs root filesystem (`compress=zstd`, `noatime`).
- `/persist/bulk`: Bulk storage Btrfs filesystem (if `bulkDisks` defined).

### 2. Wipe-on-Boot Mode (`usePersistence = true`)

- `/`: 4GB in-memory `tmpfs` (wiped cleanly on every reboot).
- `/boot`: 2GB EFI System Partition.
- `/mnt-root`: Root subvolume.
- `/nix`: Immutable Nix store subvolume (`/nix`).
- `/persist`: Stateful persistent subvolume (`/persist`).
- `/persist/bulk`: Secondary bulk storage pool (`/persist/bulk`).

______________________________________________________________________

## 🔄 Easy Drive Swapping & Expansion

### 1. Using Persistent Hardware IDs (`/dev/disk/by-id/`)

To prevent device letters (`/dev/sda` vs `/dev/sdb`) from swapping across reboots, specify persistent device identifiers:

```nix
speedDisks = [ "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNF0R123456" ];
bulkDisks = [ "/dev/disk/by-id/ata-WDC_WD40EFRX-68N32N0_WD-WCC7K1234567" ];
```

### 2. Live Zero-Downtime Drive Replacement (Btrfs)

For live NAS or storage servers:

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

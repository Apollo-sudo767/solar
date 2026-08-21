# Drive Swapping & Pool Expansion 🔄

The Solar Disko architecture is hardware-aware and designed for **seamless drive replacement, disk swaps, and storage expansion**.

______________________________________________________________________

## 1. Using Persistent Drive Identifiers (`/dev/disk/by-id/`)

Linux device names like `/dev/sda` and `/dev/sdb` can occasionally change order across reboots when hardware cables or controllers are reordered. To ensure drive swaps are 100% deterministic, specify drives by their persistent hardware ID:

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

## 2. Declarative Drive Replacement (via Disko)

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

## 3. Live Zero-Downtime Drive Swapping (via Native Btrfs)

For active NAS and storage servers (**ganymede** and **callisto**), Btrfs allows you to hot-swap or replace drives **live without unmounting shares or taking the storage offline**:

### Live Replacing a Drive in the Btrfs Pool:

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

### Adding a New Drive to Expand Storage:

```bash
# Format and open LUKS on the new drive:
sudo cryptsetup luksFormat --type luks2 /dev/sdd1
sudo cryptsetup open /dev/sdd1 crypted-bulk-extra

# Add the new device into the bulk storage pool:
sudo btrfs device add /dev/mapper/crypted-bulk-extra /persist/bulk

# Rebalance data across all drives (optional, runs in background):
sudo btrfs balance start /persist/bulk
```

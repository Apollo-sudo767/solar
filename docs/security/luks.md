# Full-Disk LUKS Encryption 🔐

Disko automatically configures **LUKS2 encryption** on all `speedDisks` and `bulkDisks` when `enableLuks = true` (default on `thebe`, `ganymede`, and `callisto`).

______________________________________________________________________

## 🔑 Crucial: Same Passphrase for Multi-Disk & Automated Reboots

> [!IMPORTANT]
> **ALWAYS set the exact same LUKS passphrase across all encrypted drives in a multi-disk machine.**

### Why this is required:

1. **Single-Prompt Booting:** During early boot (`initrd`), `systemd-cryptsetup` caches the passphrase entered for the root disk and automatically tries it against all remaining encrypted disks. If all disks share the same passphrase, you only type your password **once** on boot rather than once per drive.
1. **Automating Reboots & Remote Restarts:** When automating reboots or deploying remotely, mismatched passphrases will cause the boot sequence to stall waiting for secondary disk passwords.
1. **TPM 2.0 Fallback:** If TPM2 auto-unlock ever requires manual fallback (e.g. after a firmware update), typing the passphrase once unlocks the entire storage array simultaneously.

______________________________________________________________________

## 🛠️ Synchronizing / Adding Passphrases

If you ever need to synchronize or add the same passphrase across existing drives:

```bash
# Add the primary passphrase to your bulk disk(s):
sudo cryptsetup luksAddKey /dev/sda1
sudo cryptsetup luksAddKey /dev/sdb1
```

______________________________________________________________________

## 🛡️ Adding a Secondary Recovery Passphrase

After booting into the installed system, it is strongly recommended to add a secondary recovery passphrase to key slot 1:

```bash
# Identify your encrypted partition (e.g., /dev/nvme0n1p2 or /dev/sda2)
lsblk -f

# Add a secondary recovery passphrase:
sudo cryptsetup luksAddKey /dev/nvme0n1p2
```

______________________________________________________________________

## 🔍 Inspecting Key Slots

You can verify active key slots and encryption parameters at any time:

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2
```

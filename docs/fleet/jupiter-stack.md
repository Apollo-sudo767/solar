# The Jupiter Moon Stack 🌕

The Jupiter moon stack consists of three purpose-built, standalone hosts designed to run without any dependencies on external secret repositories.

______________________________________________________________________

## 🛰️ 1. Thebe (Intel Mac Mini)

- **Role**: Compact desktop / server node.
- **Hardware**: Intel Core CPU, Intel iGPU, Apple SMC controller.
- **Bootloader**: Native UEFI `limine` with graphical splash.
- **Storage Topology**: Single SATA/NVMe SSD managed via Disko with LUKS2 encryption and Btrfs root filesystem (`compress=zstd`, `noatime`).
- **Security & Features**: AppArmor, `applesmc` thermal sensor monitoring, Tailscale mesh VPN, and OpenSSH.

______________________________________________________________________

## 🗄️ 2. Ganymede (Dedicated NAS)

- **Role**: Dedicated Network Attached Storage (NAS) server.
- **Hardware**: Multi-drive storage array with SAS/SATA HBA support.
- **Storage Topology**:
  - `speedDisks`: Fast NVMe/SSD for OS and caching.
  - `bulkDisks`: Multi-HDD pool assembled as Btrfs (`-L bulk`) mounted at `/persist/bulk`.
  - **Encryption**: Full LUKS2 encryption across all drives with TPM2 auto-unlock.
- **Services**:
  - **Samba (SMB3)**: High-performance file sharing locked to SMB3 minimum with restricted LAN/Tailscale CIDR blocks.
  - **NFS Server**: NFSv4 exports for high-speed Linux client mounts.
  - **Avahi / mDNS**: Zero-configuration discovery (`smb://ganymede.local/storage`).
  - **Disk Health**: Automated weekly Btrfs scrubbing and `smartd` SMART monitoring.

______________________________________________________________________

## 💾 3. Callisto (General Storage & Backup)

- **Role**: Central backup repository and continuous folder synchronization server.
- **Storage Topology**: NVMe fast primary drive + secondary bulk HDD pool mounted at `/persist/bulk` with LUKS2 encryption.
- **Services**:
  - **Syncthing**: Continuous peer-to-peer folder synchronization bound securely to local interface (`127.0.0.1:8384`).
  - **Backup Tooling**: Built-in `restic`, `borgbackup`, `rclone`, `rsync`, and `ncdu`.
  - **Maintenance**: Automated weekly Btrfs scrubbing and `smartd` disk diagnostics.

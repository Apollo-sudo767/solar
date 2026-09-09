# Server & Cloud Infrastructure 🌐

______________________________________________________________________

## ☁️ Venus (Multi-Service Home Cloud)

**Venus** is a multi-service Linux server providing web hosting, encrypted synchronization, and multiplayer gaming.

### 🌐 Web & Proxy Services

- **Nginx Reverse Proxy**: Automatic SSL termination using Lego ACME client.
- **Dynamic DNS (DDNS)**: Automated multi-domain dynamic DNS updater for:
  - `joplin.apollan.cc`
  - `zotero.apollan.cc`
  - `languagetool.apollan.cc`
  - `factorio.apollan.cc`
  - `nomansland.apollan.cc`

### 📚 Self-Hosted Productivity

- **Joplin Server**: Encrypted cloud note synchronization.
- **Zotero Server**: Academic research and bibliography synchronization backend.
- **LanguageTool Server**: Self-hosted grammar and spelling correction API.

### 🎮 Dedicated Game Servers

- **Factorio**: Dedicated game server listening on UDP port 34197.
- **Minecraft No Man's Land**: PhasMC 1.21.1 NeoForge modpack server listening on port 19132 (Simple Voice Chat on UDP 24454).
- **Minecraft SLLV**: Dedicated survival server listening on port 25565.

______________________________________________________________________

## ⚡ Phosphorus (Lenovo ThinkCentre M720q Tiny)

**Phosphorus** (*Morning Star / Φωσφόρος*) is a dedicated K3s cluster node.

- **Hardware**: Lenovo ThinkCentre M720q Tiny (Intel Core CPU, Intel UHD 630 Graphics)
- **Memory**: 16 GB DDR4 SODIMM
- **Storage**: Universal Disko Btrfs on NVMe (`/dev/nvme0n1`)
- **Bootloader**: Limine UEFI
- **Role**: K3s control-plane / worker peer to Venus and Hesperus
- **Networking & Firewall**: Key-only SSH (port 22), K3s supervisor API (port 6443), etcd HA ports (2379, 2380), Kubelet metrics (10250), Flannel VXLAN (UDP 8472), Tailscale mesh connectivity.

______________________________________________________________________

## 🌟 Hesperus (Lenovo ThinkCentre M920q Tiny)

**Hesperus** (*Evening Star / Ἕσπερος*) is a high-capacity K3s cluster node.

- **Hardware**: Lenovo ThinkCentre M920q Tiny (Intel Core CPU with vPro / Intel UHD 630 Graphics, PCIe expansion capable)
- **Memory**: 32 GB DDR4 SODIMM
- **Storage**: Universal Disko Btrfs on NVMe (`/dev/nvme0n1`)
- **Bootloader**: Limine UEFI
- **Role**: K3s control-plane / worker peer to Venus and Phosphorus
- **Networking & Firewall**: Key-only SSH (port 22), K3s supervisor API (port 6443), etcd HA ports (2379, 2380), Kubelet metrics (10250), Flannel VXLAN (UDP 8472), Tailscale mesh connectivity.

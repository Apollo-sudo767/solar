# Server & Cloud Infrastructure 🌐

Solar powers both multi-service cloud nodes and compact bare-metal servers designed for continuous, headless operation.

______________________________________________________________________

## ☁️ 1. Venus (Multi-Service Home Cloud)

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

## 🛰️ 2. Thebe (Intel Mac Mini Server)

**Thebe** is a compact, standalone bare-metal server node running on repurposed Intel Mac Mini hardware:

- **Hardware**: Intel Core CPU, Intel iGPU, Apple SMC controller.
- **Role**: Compact headless server node (`suites.server`).
- **Bootloader**: Native UEFI `limine` with graphical splash.
- **Storage Topology**: Single SATA/NVMe SSD managed via Disko with LUKS2 encryption and Btrfs root filesystem (`compress=zstd`, `noatime`).
- **Security & Features**: AppArmor MAC profiles, `applesmc` thermal sensor monitoring, Tailscale mesh VPN, and key-only OpenSSH.
- **Zero-Secret Bootstrap**: Operates completely self-contained with zero dependencies on private secret repositories.

______________________________________________________________________

## ⚠️ Deprecated Legacy Hosts

> [!NOTE]
> The former Jupiter Moon storage nodes have been retired in favor of the centralized storage and compute topology:
>
> - **`ganymede`** (Dedicated NAS): **Deprecated** — superseded by **`sol`** (Central ZFS NAS).
> - **`callisto`** (Storage & Backup): **Deprecated** — superseded by **`sol`** and the **Pluto Cluster**.
> - **`thebe`** remains actively maintained as a standalone compact server node.

______________________________________________________________________

## 🧭 Navigation & Next Steps

- **[Explore The Pluto Cluster](pluto-cluster.md)** ➔
- **[Return to Fleet Overview](overview.md)** ➔
- **[Return to Documentation Home](../index.md)** ➔

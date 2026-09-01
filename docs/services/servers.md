# Dedicated Servers & Storage Daemons 🗄️

Solar provisions dedicated multiplayer game servers, cloud applications, and network storage daemons.

______________________________________________________________________

## 🎮 1. Dedicated Game Servers

### Minecraft (via `nix-minecraft`)

- **No Man's Land (`no-mans-land.nix`)**: PhasMC No Man's Land 1.21.1 NeoForge modpack server on port 25565 with Simple Voice Chat on UDP port 24454 and automated BorgBackup.
- **Create Aero (`create-aero.nix`)**: Heavy modded Minecraft server on port 19132 with optimized garbage collection flags.
- **SLLV (`sllv.nix`)**: Vanilla/survival multiplayer server on port 25565.
- **Minecraft Admin (`admin.nix`)**: Dedicated administrative user and toolchain.

### Factorio (`factorio.nix`)

- Dedicated headless Factorio server listening on UDP port 34197.

### Terraria (`terraria.nix`)

- TShock / vanilla Terraria dedicated multiplayer server.

______________________________________________________________________

## 📚 2. Self-Hosted Cloud Applications

- **Joplin Server (`joplin.nix`)**: Encrypted cloud note synchronization backend.
- **Zotero Server (`zotero.nix`)**: Self-hosted academic research library and attachment storage.
- **LanguageTool Server (`languagetool.nix`)**: Private grammar and spelling API.
- **Trilium Notes (`trilium.nix`)**: Hierarchical note-taking server.

______________________________________________________________________

## 🗄️ 3. Storage Sharing Daemons

- **Samba (SMB3)**: High-throughput Windows/macOS/Linux network file shares locked to SMB3 with strict subnet access.
- **NFS Server**: High-speed NFSv4 exports for Linux workstations and storage arrays.

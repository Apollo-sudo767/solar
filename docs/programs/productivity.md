# Productivity & Office Applications 📄

Solar includes declarative suites for web browsing, credential management, team communication, and document authoring.

______________________________________________________________________

## 🌐 1. Web Browsers (`browsers/`)

- **Firefox Nightly** (`firefox.nix`): Hardened profile integration with userChrome styling and declarative extension provisioning.
- **Zen Browser** (`zen.nix`): Vertical tabs and modern workspace isolation.
- **Google Chrome** (`chrome.nix`): Chromium-based web testing and media compatibility.

______________________________________________________________________

## 💬 2. Social & Utilities (`utilities/`)

- **Bitwarden** (`bitwarden.nix`): Official password manager desktop client and CLI integration.
- **Vesktop** (`vesktop.nix`): Enhanced Discord client with Vencord plugins, Wayland screen sharing with audio, and native window decoration options.
- **Spotify** (`spotify.nix`): Desktop player and Spotify-TUI terminal player.
- **File Manager** (`filemanager.nix`): Thunar (GTK) or Dolphin (Qt) file managers with archive and volume plugins.
- **Logseq** (`logseq.nix`): Privacy-first, local-first knowledge base and outliner.

______________________________________________________________________

## 📚 3. AP-Office Suite (`office/ap-office.nix`)

A unified meta-module bundling complete document and academic toolchains:

- **Document Editors**: OnlyOffice, LibreOffice, SoftMaker Office, and Calligra.
- **Note-Taking & Research**: Joplin, Trilium Notes, and Zotero academic bibliography manager.
- **Typography & Publishing**: Typst and Pandoc for modern technical document generation.
- **Writing Assistance**: LanguageTool grammar checking backend integration.

# System Architecture 🌲

The core architectural innovation of **Solar** is the **Dendritic Tree**—an automated module scanner that models the entire fleet of machines as a single interconnected module graph.

______________________________________________________________________

## 🏗️ Directory Hierarchy

```text
Solar
├── flake.nix               # Entry point (flake-parts orchestration)
├── flake.lock              # Pinned flake dependencies
├── book.toml               # Interactive documentation configuration
├── install.sh              # Interactive deployment wizard
├── INSTALL.md              # Bare-metal installation guide
├── assets/                 # Centralized wallpapers, icons, and themes
├── docs/                   # Interactive mdBook documentation source
├── modules/                # The Dendritic Core
│   ├── default.nix         # Autoscanner (platform filtering via isDarwin & isTotal)
│   ├── core/               # Cross-platform foundation (users, shell, disko, boot, security)
│   ├── darwin/             # macOS-exclusive modules (Homebrew, system defaults)
│   ├── hardware/           # Linux-exclusive hardware modules (CPU, GPU, input, sensors)
│   ├── programs/           # Feature modules (Browsers, Terminals, Media, Office)
│   ├── services/           # System services (Networking, Samba, NFS, Game Servers)
│   ├── platforms/          # Desktop Environments (GNOME, KDE, Niri, COSMIC)
│   └── hosts/              # Machine Configurations (The Terminal Leaves)
│       └── default.nix     # Automated host loader
├── parts/                  # Flake-parts modular definitions
└── templates/              # Blueprints for new hosts and features
```

______________________________________________________________________

## 🔍 How Automatic Discovery Works

In traditional Nix flakes, every new module or host requires manual imports in multiple configuration files. Solar eliminates this boilerplate through two autoloader engines:

### 1. The Global Module Autoscanner (`modules/default.nix`)

Recursively walks all subdirectories of `modules/` (excluding `hosts/`) and extracts every `.nix` file. It safely detects argument signatures:

- **`isDarwin`**: Evaluated strictly on macOS systems.
- **`isTotal`**: Universal modules that evaluate on both Linux and macOS.
- **Linux Default**: Modules without platform flags are automatically loaded on all Linux configurations and completely omitted from macOS evaluation to prevent evaluation errors.

### 2. The Host Loader (`modules/hosts/default.nix`)

Scans `modules/hosts/` for subdirectories (excluding `shared/`). For each host:

1. Reads the `meta` attribute set in `modules/hosts/<hostname>/default.nix` for system architecture (`x86_64-linux`, `aarch64-darwin`, etc.), release channel (`stable` vs `unstable`), and secret toggles.
1. Directs the build to either `pkgs.lib.nixosSystem` or `inputs.nix-darwin.lib.darwinSystem`.
1. Injects Home Manager, Disko, Preservation, and Agenix modules dynamically.
1. Exposes the resulting configurations under `nixosConfigurations.<hostname>` and `darwinConfigurations.<hostname>`.

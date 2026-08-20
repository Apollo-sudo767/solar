# Solar ☀️

______________________________________________________________________

## ❄️ Fully Automated Dendritic Flake

A hybrid NixOS & macOS configuration structured like a tree | Modular, Automated, and purely Nix declarative.

![limine-bg](assets/wallpapers/limine-bg.png)

## 🌲 The Dendritic Tree

New features and hosts are automatically discovered and integrated. This structure treats the fleet of machines it serves as a single unified module tree, using smart recursion to filter modules based on the target platform.

```text
Solar
├── flake.nix               # Entry point (generates nixosConfigurations and darwinConfigurations)
├── flake.lock
├── install.sh              # Interactive bare-metal deployment wizard
├── INSTALL.md              # Bare-metal installation & storage guide
├── assets/                 # Icons, wallpapers, and screenshots
├── modules/                # The Dendritic Core
│   ├── default.nix         # Autoscanner (filters via 'isDarwin' and 'isTotal')
│   ├── core/               # Cross-platform essentials (users, shell, disko, boot, security)
│   ├── darwin/             # macOS-exclusive settings (Homebrew, system defaults)
│   ├── hardware/           # Linux-exclusive hardware logic (AMD, Intel, Nvidia, etc.)
│   ├── programs/           # Feature modules (Browsers, Terminals, Media, Office)
│   ├── services/           # System services (Networking, Samba, NFS, Game Servers)
│   ├── platforms/          # Desktop Environments (GNOME, KDE, Niri, COSMIC)
│   └── hosts/              # The Terminal Leaves (Individual Machine Configs)
│       ├── default.nix     # Dual-purpose host loader
│       ├── thebe/          # Intel Mac Mini (Disko LUKS + Btrfs, Limine)
│       ├── ganymede/       # Dedicated NAS (Samba SMB3, NFS, Btrfs Scrub)
│       ├── callisto/       # General Storage & Backup (Syncthing, Btrfs Scrub)
│       ├── mars/           # Main Workstation (Niri, Wipe-on-Boot tmpfs)
│       ├── mercury/        # Portable Laptop (Niri, Battery tuning)
│       ├── elara/          # Gaming & Media Rig (KDE Plasma, Sunshine)
│       ├── europa/         # VR & Media Rig (KDE Plasma, Meta Quest VR)
│       ├── amalthea/       # Handheld Gaming Console (Steam Big Picture)
│       ├── io/             # COSMIC DE Testbed Node
│       ├── phobos/         # Apple Silicon MacBook (nix-darwin)
│       └── venus/          # Multi-Service Home Server (Nginx, Joplin, Zotero, Games)
├── parts/                  # Flake-parts organization
└── templates/              # Blueprints for new hosts and features
```

## 🪐 The Fleet

### 🌕 The Jupiter Moon Stack *(Disko + Btrfs + LUKS)*

Self-contained, standalone hosts with **zero dependencies on private secret repositories or agenix**.

- **`thebe`** — *Intel Mac Mini*: Compact server/desktop node, Apple SMC thermal monitoring, Limine bootloader, Disko LUKS + Btrfs SSD, AppArmor, Tailscale.
- **`ganymede`** — *Dedicated NAS*: NVMe cache + multi-HDD Btrfs storage pool, Samba (SMB3 enforced), NFSv4 server, Avahi mDNS auto-discovery, SMART diagnostics, weekly Btrfs scrubs.
- **`callisto`** — *General Storage & Backup*: Multi-drive Btrfs storage pool, Syncthing peer folder sync, backup utilities (Restic, Borg, Rclone, Rsync), SMART monitoring.

### 🚀 Personal Workstations, Laptops & Devices

- **`mars`** — *Primary Workstation*: AMD CPU + Nvidia GPU, Niri scrollable Wayland compositor, ReGreet, wipe-on-boot tmpfs persistence, multi-NVMe + HDD Btrfs pool, Sunshine game streaming, Wooting keyboard support.
- **`mercury`** — *Laptop*: Intel CPU/iGPU, Niri Wayland compositor, aggressive power/battery profiles, trackpad gestures, wipe-on-boot tmpfs persistence.
- **`elara`** — *Gaming & Media Rig*: AMD CPU + Nvidia GPU, KDE Plasma, SDDM, Stylix Strawberry theme, Steam Gamescope, Sunshine streaming server, DaVinci Resolve.
- **`europa`** — *VR & Media Rig*: Intel CPU + Nvidia GPU, KDE Plasma, Meta Quest wired VR support, video recording/editing suite.
- **`amalthea`** — *Handheld Console*: Intel Atom z8350, auto-boots directly into Steam Big Picture via Gamescope on KDE Plasma.
- **`phobos`** — *MacBook*: Apple Silicon (`aarch64-darwin`) managed via `nix-darwin`, Homebrew bundle integration, dark mode defaults, Logseq, Raycast.
- **`io`** — *Testbed*: Rust-based COSMIC Desktop Environment & COSMIC Greeter, Stylix Space theme.

### 🌐 Home Server & Cloud Services

- **`venus`** — *Multi-Service Home Server*: Nginx reverse proxy with automated Dynamic DNS & Lego SSL certificates, Joplin Server, Zotero sync server, LanguageTool server, dedicated Factorio & Minecraft servers.

## 🎨 Visual Styling

Managed via **Stylix**. Wallpapers and themes are centralized in the `assets/` folder, ensuring a consistent look across all managed machines.

## 🚀 Enabling Features

Every module in the `/modules` directory can be enabled via a simple toggle in your host configuration:

```nix
# Inside modules/hosts/<hostname>/default.nix
myFeatures.programs.helix.enable = true;
myFeatures.platforms.niri.enable = true;
```

## ⚙️ Prerequisites

Before deploying, ensure the target machine has Nix installed with experimental features enabled in `nix.conf`:

```conf
experimental-features = nix-command flakes
```

## ⚒️ Deployment Instructions

For complete step-by-step bare-metal installation instructions, see [INSTALL.md](INSTALL.md).

### Automated Installation

Run the interactive installation wizard:

```bash
./install.sh
```

### Initial Bootstrap

To apply a configuration to a new machine for the first time:

**NixOS:**

```bash
sudo nixos-rebuild boot --flake .#<hostname>
```

**macOS:**

```bash
nix run nix-darwin -- switch --flake .#phobos
```

### Regular Updates

Once bootstrapped, use the built-in aliases for efficiency:

```bash
# Update flake inputs
nfu  # (nix flake update)

# Apply changes (NixOS)
nrs  # (nixos-rebuild switch)
nrb  # (nixos-rebuild boot - apply on next reboot)

# Apply changes (macOS)
drs  # (darwin-rebuild switch)
```

## 🍼 Creating New Hosts

Use the provided templates to quickly spin up new configurations:

```bash
cp -r templates/hosts.nix modules/hosts/<new-host>/default.nix
```

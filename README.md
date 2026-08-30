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
│   ├── darwin/             # macOS-exclusive settings (Homebrew, system defaults, suites)
│   ├── hardware/           # Linux-exclusive hardware logic (AMD, Intel, Nvidia, etc.)
│   ├── platforms/          # Desktop Environments (18 WMs/DEs: Niri, Hyprland, Sway, MangoWC, KDE, etc.)
│   ├── suites/             # Dendritic Composite Suites (Workstation, Gaming, Creator, Server, Desktops)
│   ├── programs/           # Feature modules (Browsers, Terminals, Media, Office, Utilities)
│   ├── services/           # System services (Networking, Samba, NFS, Game Servers)
│   └── hosts/              # The Terminal Leaves (Individual Machine Configs)
│       ├── default.nix     # Dual-purpose host loader
│       ├── thebe/          # Intel Mac Mini (Server Suite, Limine)
│       ├── ganymede/       # Dedicated NAS (Server Suite, Samba SMB3, NFS)
│       ├── callisto/       # Storage & Backup (Server Suite, Btrfs Pool)
│       ├── mars/           # Main Workstation (Workstation, Gaming, Creator, Niri Suite)
│       ├── mercury/        # Portable Laptop (Workstation, Laptop, Niri Suite)
│       ├── elara/          # Gaming Rig (Workstation, Gaming, Plasma Suite)
│       ├── europa/         # Hybrid Laptop Rig (Workstation, Gaming, Laptop, Plasma Suite)
│       ├── amalthea/       # Handheld Console (Gaming Suite, Steam Big Picture)
│       ├── io/             # COSMIC DE Testbed Node (Workstation, COSMIC Suite)
│       ├── phobos/         # Apple Silicon MacBook (Darwin Workstation Suite)
│       └── venus/          # Multi-Service Cloud Server (Server Suite, Nginx, Joplin, Games)
├── parts/                  # Flake-parts organization
└── templates/              # Blueprints for new hosts and features
```

## 🪐 The Fleet

### 🌕 The Jupiter Moon Stack *(Disko + Btrfs + LUKS)*

Self-contained, standalone hosts with **zero dependencies on private secret repositories or agenix**.

- **`thebe`** — *Intel Mac Mini*: Compact server node, `suites.server`, Apple SMC thermal monitoring, Limine bootloader, Disko LUKS + Btrfs SSD, AppArmor, Tailscale.
- **`ganymede`** — *Dedicated NAS*: `suites.server`, NVMe cache + multi-HDD Btrfs storage pool, Samba (SMB3 enforced), NFSv4 server, Avahi mDNS auto-discovery, SMART diagnostics, weekly Btrfs scrubs.
- **`callisto`** — *General Storage & Backup*: `suites.server`, multi-drive Btrfs storage pool, Syncthing peer folder sync, backup utilities (Restic, Borg, Rclone, Rsync), SMART monitoring.

### 🚀 Personal Workstations, Laptops & Devices

- **`mars`** — *Primary Workstation*: AMD CPU + Nvidia GPU, `suites.workstation`, `suites.gaming`, `suites.creator`, `suites.streaming`, `suites.desktops.niri`, Stylix Sky theme, ReGreet, wipe-on-boot tmpfs persistence, multi-NVMe + HDD Btrfs pool, Wooting analog keyboard.
- **`mercury`** — *Laptop*: Intel CPU/iGPU, `suites.workstation`, `suites.gaming`, `suites.laptop`, `suites.desktops.niri`, Stylix Sky theme, ReGreet, wipe-on-boot tmpfs persistence.
- **`elara`** — *Gaming & Media Rig*: AMD CPU + Nvidia GPU, `suites.workstation`, `suites.gaming`, `suites.desktops.plasma`, Stylix Strawberry theme, SDDM, DaVinci Resolve.
- **`europa`** — *Hybrid Laptop Rig*: Intel + Nvidia GPU, `suites.workstation`, `suites.gaming`, `suites.laptop`, `suites.desktops.plasma`, Stylix Forest theme, SDDM.
- **`amalthea`** — *Handheld Console*: Intel Atom z8350, `suites.gaming`, `suites.desktops.plasma`, auto-boots directly into Steam Big Picture via Gamescope.
- **`phobos`** — *MacBook*: Apple Silicon (`aarch64-darwin`) managed via `nix-darwin`, `suites.darwinWorkstation`, Stylix Sky theme, Homebrew bundle integration, Logseq, Raycast.
- **`io`** — *Testbed*: `suites.workstation`, `suites.desktops.cosmic`, Stylix Space theme, COSMIC Greeter.

### 🌐 Home Server & Cloud Services

- **`venus`** — *Multi-Service Cloud Server*: `suites.server`, Nginx reverse proxy with automated Dynamic DNS & Lego SSL certificates, Joplin Server, Zotero sync server, LanguageTool server, dedicated Factorio & Minecraft servers.

## 🎨 Visual Styling

Managed via **Stylix**. Themes and color palettes are decided strictly per host in `modules/hosts/<hostname>/default.nix`, ensuring total aesthetic control per machine without suite interference.

## 🚀 Enabling Suites & Features

Activate high-level domain suites or individual granular features directly in your host configuration:

```nix
# Inside modules/hosts/<hostname>/default.nix
myFeatures.suites = {
  workstation.enable = true;
  gaming.enable = true;
  desktops.niri.enable = true;
};

# Or fine-grained individual options:
myFeatures.programs.terminal.helix.enable = true;
myFeatures.platforms.desktops.hyprland.enable = true;
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

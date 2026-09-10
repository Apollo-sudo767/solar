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
│       ├── pluto/          # Pluto Cluster Bootstrap Master (K3s HA, Ryzen 7, Minecraft)
│       ├── styx/           # Pluto Cluster Control-Plane Master (ThinkPad T14, Battery UPS)
│       ├── hydra/          # Pluto Cluster Control-Plane Master (ThinkCentre, QuickSync GPU)
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

## 📖 Documentation & Navigation Hub

Solar features extensive, automated documentation generated via **mdBook** and published directly to GitHub Pages:

👉 **[Browse the Solar Documentation Site](https://apollo-sudo767.github.io/solar/)** • **[Local Source (`docs/`)](docs/)**

| Section | Description | Quick Links |
| :--- | :--- | :--- |
| 🧠 **Wiki & Knowledge Base** | Technical guides, option toggles, keybindings, and troubleshooting | [Quick Reference](docs/wiki/quick-reference.md) • [Toggle List](docs/wiki/definitive-toggle-list.md) • [Keybindings](docs/wiki/keybinds.md) • [Troubleshooting](docs/wiki/troubleshooting.md) • [FAQ](docs/wiki/faq.md) |
| 🪐 **The Fleet** | Hardware specs, machine roles, and the Pluto Kubernetes cluster | [Fleet Overview](docs/fleet/overview.md) • [Workstations](docs/fleet/workstations.md) • [Gaming & VR](docs/fleet/gaming-vr.md) • [The Pluto Cluster](docs/fleet/pluto-cluster.md) • [Cloud & Servers](docs/fleet/servers.md) |
| 🌲 **Suites & Profiles** | Dendritic 3-tier architecture, role suites, and desktop profiles | [Suites Overview](docs/suites/overview.md) • [Role Suites](docs/suites/roles.md) • [Desktop Suites](docs/suites/desktops.md) |
| 🖥️ **Platforms & Desktops** | 18 graphical compositors, window managers, greeters, and Stylix styling | [Compositors Overview](docs/platforms/desktops.md) • [Wayland](docs/platforms/wayland.md) • [X11](docs/platforms/x11.md) • [DEs](docs/platforms/desktop-environments.md) • [Styling](docs/platforms/styling.md) |
| 🎮 **Programs & Toolchains** | Steam, Gamescope, TF2, VR, Ghostty terminal, Helix, and Office | [Gaming](docs/programs/gaming.md) • [Virtual Reality](docs/programs/vr.md) • [Terminal & Dev](docs/programs/terminal.md) • [Productivity](docs/programs/productivity.md) |
| 💾 **Storage & Security** | Ephemeral root tmpfs, Disko pools, LUKS2, Secure Boot, and Agenix secrets | [Universal Disko](docs/storage/disko.md) • [Wipe-on-Boot](docs/storage/preservation.md) • [LUKS2](docs/security/luks.md) • [Secure Boot](docs/security/secureboot.md) • [TPM 2.0](docs/security/tpm2.md) • [Agenix](docs/security/agenix.md) |
| 🚀 **Deployment & Guides** | Bare-metal installation wizard, system maintenance, and module creation | [Installation Guide](docs/deployment/installation.md) • [Maintenance](docs/deployment/maintenance.md) • [How Modules Work](docs/guides/how-modules-work.md) • [Adding a Host](docs/guides/adding-a-host.md) |

______________________________________________________________________

## 🪐 The Fleet

### 🪐 The Pluto Cluster *(High-Availability K3s + GitOps + ZFS NAS)*

A 3-node High-Availability Kubernetes (K3s) GitOps cluster managed via [Flux CD](https://github.com/Apollo-sudo767/pluto-cluster) and NixOS:

- **`pluto`** — *Bootstrap Master*: Beelink EQR5 (Ryzen 7 5825U, 32GB RAM, NVMe), `clusterInit = true`, `node.type=compute`, secrets sync daemon, dedicated Paper Minecraft host with Playit.gg anycast sidecar tunnel.
- **`styx`** — *Control-Plane Master*: Lenovo ThinkPad T14 Gen 2 (i5, 16GB RAM, NVMe), built-in battery UPS capped at 50% (`TLP`), lid-switch ignored, embedded etcd quorum peer.
- **`hydra`** — *Control-Plane Master & Transcoder*: Lenovo ThinkCentre M920q Tiny (i5-8500T, 16GB RAM, NVMe), `gpu.vendor=intel`, Intel QuickSync GPU hardware passthrough (`/dev/dri`) for Jellyfin video transcoding.
- **`sol`** — *Central Fleet ZFS NAS*: Storage hub exporting `/tank/k3s-volumes` via dynamic NFS (`nfs-client` provisioner).

📖 **For detailed architecture, secrets sync, and workloads, see [The Pluto Cluster Documentation](docs/fleet/pluto-cluster.md) and the [GitOps Repository](https://github.com/Apollo-sudo767/pluto-cluster).**

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

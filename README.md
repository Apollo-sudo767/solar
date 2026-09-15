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
│       ├── pluto/          # Pluto Cluster Bootstrap Master (K3s HA, Beelink EQR5, Ryzen 7 5825u, 32GB RAM)
│       ├── styx/           # Pluto Cluster Control-Plane Master (ThinkCentre M720q Tiny, i5-9500T, 16GB RAM)
│       ├── hydra/          # Pluto Cluster Control-Plane Master (ThinkCentre, M920q Tiny, 15-8500T, 24GB RAM)
│       ├── mars/           # Main Workstation (Workstation, Gaming, Creator, Niri Suite)
│       ├── mercury/        # Portable Laptop (Workstation, Laptop, Niri Suite)
│       ├── elara/          # Gaming Rig (Workstation, Gaming, Plasma Suite)
│       ├── europa/         # Hybrid Laptop Rig (Workstation, Gaming, Laptop, Plasma Suite)
│       ├── amalthea/       # Handheld Console (Gaming Suite, Steam Big Picture)
│       ├── io/             # COSMIC DE Testbed Node (Workstation, COSMIC Suite)
│       ├── phobos/         # Apple Silicon MacBook (Darwin Workstation Suite)
│       ├── thebe/          # Compact Standalone Server (Intel Mac Mini, Limine)
│       ├── venus/          # Multi-Service Cloud Server (Server Suite, Nginx, Joplin, Games)
│       ├── sol/            # Central Fleet ZFS NAS & Storage Hub (Server Suite, Limine, ZFS Mirror Pool)
│       ├── pluto/          # K3s HA Bootstrap Master (Beelink EQR5 Ryzen 7 32GB, Preservation, Agenix)
│       ├── styx/           # K3s HA Master Node 2 (ThinkCentre M720q Tiny i5-9500T 16GB, Agenix)
│       └── hydra/          # K3s HA Master Node 3 (ThinkCentre M920q i5-8500T 24GB, QuickSync GPU, Agenix)
├── parts/                  # Flake-parts organization
└── templates/              # Blueprints for new hosts and features
```

## 📖 Documentation & Developer Portal

Solar features an official developer documentation portal built with **VitePress** and published automatically via GitHub Pages:

👉 **[Browse the Solar Documentation Portal](https://apollo-sudo767.github.io/solar/)** • **[Local Source (`docs/`)](docs/)**

| Portal Section | Highlights & Key Guides | Quick Links |
| :--- | :--- | :--- |
| 🚀 **Guides & Blueprints** | Bare-metal installation, desktop blueprints, server configuration, and routine updates | [Getting Started](docs/guide/getting-started.md) • [Module Guide](docs/guide/modules.md) |
| 🌲 **Architecture** | Dendritic tree pattern, automatic leaf discovery, and 3-tier system design | [Dendritic Architecture](docs/guide/architecture.md) |
| 🪐 **The Fleet & Clusters** | 15-host constellation map, specs, and the 3-node HA Pluto K3s cluster | [Fleet Overview](docs/fleet/index.md) • [The Pluto Cluster](docs/fleet/pluto-cluster.md) |
| 💾 **Storage & Security** | Universal Disko, ephemeral tmpfs roots, LUKS2, Limine Secure Boot, and Agenix | [Storage & Security](docs/guide/storage-security.md) |
| ⚡ **Reference & Help** | Universal command aliases, desktop keybindings, diagnostics, and toggle reference | [Cheatsheet](docs/reference/cheatsheet.md) • [Keybindings](docs/reference/keybindings.md) • [Troubleshooting](docs/reference/troubleshooting.md) • [532 Toggles](docs/reference/toggles.md) • [FAQ](docs/reference/faq.md) |

______________________________________________________________________

## 🪐 The Fleet

### 🪐 The Pluto Cluster *(High-Availability K3s + GitOps + ZFS NAS)*

A 3-node High-Availability Kubernetes (K3s) GitOps cluster managed via [Flux CD](https://github.com/Apollo-sudo767/pluto-cluster) and NixOS:

- **`pluto`** — *Bootstrap Master*: Beelink EQR5 (Ryzen 7 5825U, 32GB RAM, NVMe), `clusterInit = true`, `node.type=compute`, secrets sync daemon, dedicated Paper Minecraft host with Playit.gg anycast sidecar tunnel.
- **`styx`** — *Control-Plane Master*: Lenovo ThinkCentre M920q Tiny (i5-9500T, 16GB RAM, NVMe), `gpu.vendor=intel`, embedded etcd quorum peer.
- **`hydra`** — *Control-Plane Master & Transcoder*: Lenovo ThinkCentre M920q Tiny (i5-8500T, 24GB RAM, NVMe), `gpu.vendor=intel`, Intel QuickSync GPU hardware passthrough (`/dev/dri`) for Jellyfin video transcoding.
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

- **`sol`** — *Central Fleet ZFS NAS & Storage Hub*: `suites.server`, wipe-on-boot tmpfs root with Disko ZFS mirrored HDD pool (`/tank`), NFS dynamic k3s volume export (`/tank/k3s-volumes`), Samba (SMB3 enforced), Avahi mDNS, Agenix private secrets, SMART monitoring, weekly ZFS scrubs & snapshots.
- **`venus`** — *Multi-Service Cloud Server*: `suites.server`, Nginx reverse proxy with automated Dynamic DNS & Lego SSL certificates, Joplin Server, Zotero sync server, LanguageTool server, dedicated Factorio & Minecraft servers.
- **`thebe`** — *Compact Standalone Server*: Intel Mac Mini, `suites.server`, Apple SMC thermal monitoring, Limine bootloader, Disko LUKS + Btrfs SSD, AppArmor, Tailscale.
- *(Note: Legacy standalone storage nodes **`ganymede`** and **`callisto`** are deprecated and retired in favor of **`sol`** and the **Pluto Cluster**).*

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

### Live Installer Image / Manual Disko Installation

Boot target hardware into the Solar Live Installer USB (or a standard NixOS Minimal installer):

```bash
# Method 1: Run the interactive on-device wizard:
sudo solar-install

# Method 2: Partition and format directly via Disko:
sudo nix run github:nix-community/disko -- \
  --mode destroy,format,mount \
  --yes-wipe-all-disks \
  --flake "github:Apollo-sudo767/solar#<host>"

# Install NixOS closure:
sudo nixos-install --flake "github:Apollo-sudo767/solar#<host>" --no-root-password

# 3. Reboot:
sudo reboot
```

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

______________________________________________________________________

## 🔐 Secret Management (`agenix-rekey`)

Secrets are managed via [`agenix-rekey`](https://github.com/oddlama/agenix-rekey) and stored encrypted in [`solar-secrets`](https://github.com/Apollo-sudo767/solar-secrets). Nodes decrypt secrets locally on boot using their SSH host keys.

### 1. Creating a New Secret from Scratch

To create a brand-new secret and encrypt it with your master keys (`apollo_user` and `yubikey`):

```bash
# 1. Write the secret content to a temporary file
nano /tmp/my-secret.txt

# 2. Encrypt it into solar-secrets with age
nix shell nixpkgs#age nixpkgs#age-plugin-yubikey -c age \
  -R ~/src/solar-secrets/master/apollo_user.pub \
  -R ~/src/solar-secrets/master/yubikey.pub \
  -o ~/src/solar-secrets/secrets/<secret-name>.age \
  /tmp/my-secret.txt

# 3. Clean up the plaintext file
rm -f /tmp/my-secret.txt

# 4. Commit the new secret in solar-secrets
cd ~/src/solar-secrets
git add secrets/<secret-name>.age
git commit -m "feat(secrets): add <secret-name>"
```

### 2. Rekeying Secrets for Target Nodes

Whenever you add or modify a secret, rekey it so all target cluster machines can decrypt it:

```bash
cd ~/src/solar

# Rekey for all machines (touch your YubiKey if prompted):
s-rekey

# Commit and push the rekeyed files:
git add rekeyed/
git commit -m "chore(secrets): rekey <secret-name>"
git push origin main
```

### 3. Viewing or Editing Existing Rekeyed Secrets

To view or edit secrets that are already tracked and rekeyed in the flake:

```bash
cd ~/src/solar
s-edit
# (Opens interactive fzf picker to decrypt and view with your master identity)
```

______________________________________________________________________

## 🍼 Creating New Hosts

Use the provided templates to quickly spin up new configurations:

```bash
cp -r templates/hosts.nix modules/hosts/<new-host>/default.nix
```

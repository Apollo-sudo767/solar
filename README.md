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
│       ├── sol/            # Central Fleet ZFS NAS & Storage Hub (Server Suite, Limine, ZFS Mirror Pool)
│       ├── venus/          # Multi-Service Cloud Server (Server Suite, Nginx, Joplin, Games)
│       ├── pluto/          # K3s HA Bootstrap Master (Beelink EQR5 Ryzen 7 32GB, Preservation, Agenix)
│       ├── styx/           # K3s HA Master Node 2 (ThinkPad T14 Gen 2 16GB, Battery Cap, Agenix)
│       └── hydra/          # K3s HA Master Node 3 (ThinkCentre M920q 16GB, QuickSync GPU, Agenix)
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

- **`sol`** — *Central Fleet ZFS NAS & Storage Hub*: `suites.server`, wipe-on-boot tmpfs root with Disko ZFS mirrored HDD pool (`/tank`), NFS dynamic k3s volume export (`/tank/k3s-volumes`), Samba (SMB3 enforced), Avahi mDNS, Agenix private secrets, SMART monitoring, weekly ZFS scrubs & snapshots.
- **`venus`** — *Multi-Service Cloud Server*: `suites.server`, Nginx reverse proxy with automated Dynamic DNS & Lego SSL certificates, Joplin Server, Zotero sync server, LanguageTool server, dedicated Factorio & Minecraft servers.
- **`pluto`** — *K3s HA Bootstrap Master*: Beelink EQR5 (Ryzen 7 5825U, 32GB RAM), `suites.server`, Limine bootloader, wipe-on-boot tmpfs preservation, Agenix secrets, K3s HA control-plane cluster bootstrap master (`node.type=compute`, stateless `--disable=local-storage`), Wake-on-LAN, watchdog timer, weekly autoupgrade and staggered reboot (Sunday 03:00).
- **`styx`** — *K3s HA Master Node 2*: Lenovo ThinkPad T14 Gen 2 (16GB RAM), `suites.server`, Limine bootloader, wipe-on-boot tmpfs preservation, Agenix secrets, 40–50% battery threshold conservation, lid switch ignore, NIC power save disabled, Wake-on-LAN, watchdog timer, K3s HA control-plane master, weekly autoupgrade and staggered reboot (Sunday 03:30).
- **`hydra`** — *K3s HA Master Node 3*: Lenovo ThinkCentre M920q Tiny (Intel i5-8500T, 16GB RAM), `suites.server`, Limine bootloader, wipe-on-boot tmpfs preservation, Agenix secrets, Intel QuickSync `/dev/dri` video transcoding (`gpu.vendor=intel`), Wake-on-LAN, watchdog timer, K3s HA control-plane master, weekly autoupgrade and staggered reboot (Sunday 04:00).

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

---

## 🔐 Secret Management (`agenix-rekey`)

Secrets are managed via [`agenix-rekey`](https://github.com/oddlama/agenix-rekey) and stored encrypted in [`solar-secrets`](https://github.com/Apollo-sudo767/solar-secrets). Nodes decrypt secrets locally on boot using their SSH host keys.

### 1. Creating a New Secret from Scratch

To create a brand-new secret and encrypt it with your master keys (`apollo_user` and `yubikey`):

```bash
# 1. Write the secret content to a temporary file
nano /tmp/my-secret.txt

# 2. Encrypt it into solar-secrets with age
nix shell nixpkgs#age -c age \
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

---

## 🍼 Creating New Hosts

Use the provided templates to quickly spin up new configurations:

```bash
cp -r templates/hosts.nix modules/hosts/<new-host>/default.nix
```

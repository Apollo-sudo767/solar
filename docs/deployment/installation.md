# Bare-Metal Installation Guide 🛠️

This guide covers deploying any host configuration from the **Solar** repository onto bare-metal hardware.

______________________________________________________________________

## ⚡ Method 1: Automated Installation via `install.sh` (Recommended)

From a workstation running Linux or macOS with Nix installed:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Apollo-sudo767/solar.git
   cd solar
   ```

1. **Execute the interactive installer:**

   ```bash
   ./install.sh
   ```

1. **Follow the interactive prompts:**

   - **Host selection**: Enter target hostname (e.g. `thebe`, `ganymede`, `callisto`).
   - **Target IP**: Enter IP address of target machine (booted into a [NixOS Minimal Live USB](https://nixos.org/download.html) with `sshd` enabled).
   - **Build mode**: `1` (Local compilation) or `2` (Remote compilation).
   - **Agenix Secret Management**: Select `2` (**DISABLED** for standalone hosts).
   - **User Password**: Enter a custom password or press Enter for default.

______________________________________________________________________

## 🛠️ Method 2: Manual Installation from NixOS Live USB

If installing directly on the target machine from a Live USB:

### Step 1: Verify Disk Device Names

```bash
lsblk
```

### Step 2: Partition and Format with Disko

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode disko \
  --flake "github:Apollo-sudo767/solar#<hostname>"
```

*(Enter the identical LUKS passphrase on all drives for multi-disk systems).*

### Step 3: Install NixOS

```bash
sudo nixos-install --flake "github:Apollo-sudo767/solar#<hostname>"
```

### Step 4: Reboot

```bash
reboot
```

______________________________________________________________________

## 💿 Method 3: Dedicated Solar Live Installer ISO

Solar includes a custom live installer host (`modules/hosts/installer`) equipped with a graphical XFCE desktop, GParted, web browser, Wi-Fi configuration (`nmtui`), remote SSH authorization, and a built-in on-device installer tool (`solar-install`).

### 1. Build the Live ISO

From any machine with Nix and Linux build capability (or remote builder):

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting ISO image will be available at:
`./result/iso/solar-installer-*.iso`

### 2. Flash to USB Drive

```bash
sudo dd if=result/iso/solar-installer-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

*(Replace `/dev/sdX` with your USB drive block device).*

### 3. Boot & Install

The ISO boot menu provides two startup options:

1. **Graphical Desktop (XFCE)** (Default): Full desktop with browser, GParted, and terminal.
1. **Console / Text Mode**: Direct text console prompt with auto-login.

#### On-Device Installation

Launch the interactive installer directly from the desktop shortcut **"Install Solar"** or run in terminal:

```bash
sudo solar-install
```

The wizard will:

- Present all available hosts configured in the repository.
- Optionally generate a fresh `hardware-configuration.nix` for the detected hardware.
- Partition and format drives automatically via Disko.
- Install the NixOS system and configure initial user credentials.
- Prompt to reboot into your newly installed system.

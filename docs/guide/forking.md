# Forking & Independent Maintenance 🍴

This guide provides a comprehensive manual for forking, maintaining, and adapting **Solar** for your own fleet of machines and personal infrastructure without external dependencies.

______________________________________________________________________

## 📋 Table of Contents

1. [Initial Fork & Decoupling Checklist](#initial-fork--decoupling-checklist)
1. [Secrets Strategy & Age/YubiKey Setup](#secrets-strategy--ageyubikey-setup)
1. [Host Management: Creating, Modifying & Removing Nodes](#host-management-creating-modifying--removing-nodes)
1. [Storage, Disko & TPM 2.0 Encryption](#storage-disko--tpm-20-encryption)
1. [Adding Custom Features (Dendritic Autodiscovery)](#adding-custom-features-dendritic-autodiscovery)
1. [Daily Operations: Rebuilding, Testing & Deploying](#daily-operations-rebuilding-testing--deploying)
1. [Routine Maintenance & Upgrades](#routine-maintenance--upgrades)

______________________________________________________________________

## 🚀 Initial Fork & Decoupling Checklist

When forking the repository to your own GitHub account:

### 1. Update Git Remotes & URLs

Search and replace the upstream repository URLs with your own GitHub namespace:

- **`docs/.vitepress/config.mts`**:
  - Update `base: "/solar/"` (or `"/"` if hosted at a custom domain).
  - Update `socialLinks` and `editLink.pattern` to point to your repository.
- **`modules/hosts/installer/solar-install.sh`**:
  - Update the default clone URL in `git clone https://github.com/<your-username>/solar.git /tmp/solar`.
- **`README.md` & `INSTALL.md`**:
  - Update repo clone URLs and flake paths (`github:<your-username>/solar#<host>`).

### 2. Configure GitHub Pages (Documentation Portal)

1. In your GitHub repository settings, navigate to **Settings** → **Pages**.
1. Under **Build and deployment**, set **Source** to **GitHub Actions**.
1. Pushes to `main` will automatically build and publish VitePress via `.github/workflows/docs.yml`.

______________________________________________________________________

## 🔐 Secrets Strategy & Age/YubiKey Setup

Solar uses **Agenix-rekey** for asymmetric zero-knowledge secret encryption. As a fork maintainer, you have two options:

### Option A: Standalone Mode (No Private Secrets Repo)

If you don't need private encrypted secrets (e.g. WiFi passwords, Cloudflare tunnel credentials, VPN configs):

- In your host declarations (`modules/hosts/<hostname>/default.nix`), ensure:
  ```nix
  meta.useSecrets = false;
  ```
- Any host with `useSecrets = false` builds completely self-contained without needing access to `solar-secrets`.

### Option B: Your Own Private Secrets Repository

If you manage private fleet credentials:

1. Create a private repository on GitHub (e.g. `your-secrets`).
1. Update the `solar-secrets` input in `flake.nix`:
   ```nix
   inputs.solar-secrets = {
     url = "git+ssh://git@github.com/<your-username>/your-secrets.git?ref=main&shallow=1";
     flake = false;
   };
   ```
1. **Configure Master Identity (YubiKey or Age key)**:
   In `modules/core/security/agenix.nix`, update `masterIdentities` to list your physical YubiKey or Age public keys:
   ```nix
   age.rekey = {
     masterIdentities = [
       "age1yubikey1..."  # Output from age-plugin-yubikey
     ];
     storageMode = "local";
   };
   ```
1. **Zero-Trust Host Key Policy**:
   - **Never commit private host keys to Git.**
   - Keep host private keys locally on your management workstation (`~/.ssh/hosts/<hostname>/ssh_host_ed25519_key`).
   - Place only the public key in your secrets repo at `hosts/<hostname>.pub`.
   - Rekey secrets from your workstation using:
     ```bash
     s-rekey
     ```
     *(or: `AGENIX_REKEY_PRIMARY_FLAKE_ROOT=$HOME/src/solar AGENIX_REKEY_SECONDARY_FLAKE_ROOTS=$HOME/src/your-secrets nix run --override-input solar-secrets path:$HOME/src/your-secrets --no-write-lock-file $HOME/src/solar#agenix-rekey-rekey && git -C $HOME/src/solar add rekeyed`)*

______________________________________________________________________

## 🖥️ Host Management: Creating, Modifying & Removing Nodes

Solar features **zero-boilerplate leaf loading**. The entrypoint `flake.nix` automatically scans `modules/hosts/` and creates a `nixosConfigurations.<hostname>` or `darwinConfigurations.<hostname>` for every subdirectory.

### Adding a New Machine

1. Create a new directory: `modules/hosts/<hostname>/`
1. Create `modules/hosts/<hostname>/default.nix`:
   ```nix
   {
     meta = {
       system = "x86_64-linux"; # or "aarch64-linux", "aarch64-darwin"
       stable = false;          # false uses nixpkgs-unstable
       useSecrets = false;      # set true if host has agenix secrets
     };

     module =
       { config, lib, pkgs, ... }:
       {
         system.stateVersion = "26.11";

         myFeatures = {
           # High-Level Suites
           suites.workstation.enable = true;
           suites.gaming.enable = true;
           platforms.desktops.niri.enable = true;

           # Storage & Boot
           core = {
             system = {
               core-branch = {
                 enable = true;
                 usePersistence = true; # Ephemeral tmpfs root
               };
               disko = {
                 enable = true;
                 enableLuks = true;     # Encrypted with LUKS2
                 speedDisks = [ "/dev/nvme0n1" ];
               };
               users = {
                 usernames = [ "yourusername" ];
               };
             };
             boot = {
               enable = true;
               loader = "limine";
               kernel = "latest";
             };
           };
         };
       };
   }
   ```
1. Verify that the new host evaluates cleanly:
   ```bash
   nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath
   ```

### Removing a Machine

Simply delete or archive `modules/hosts/<hostname>/`. The flake scanner will immediately stop exporting that configuration on your next evaluation.

______________________________________________________________________

## 💾 Storage, Disko & TPM 2.0 Encryption

Solar's universal Disko module (`modules/core/system/disko.nix`) adapts automatically to your hardware and persistence preferences.

### Storage Options Matrix

| Setting | Effect | Typical Use Case |
| :--- | :--- | :--- |
| `usePersistence = true` | Root `/` is mounted in-memory on `tmpfs` and wiped on every reboot. Only `/persist` subvolume retains state. | Workstations, laptops, cluster nodes (zero rot). |
| `usePersistence = false` | Standard persistent Btrfs root filesystem mounted at `/`. | General servers, legacy machines. |
| `enableLuks = true` | Partitions the drive with LUKS2 encryption and configures `tpm2-device=auto`. | Laptops, workstations, remote-hosted nodes. |
| `enableLuks = false` | Standard unencrypted partitions. | Local testbeds, non-sensitive servers. |

### Enrolling TPM 2.0 for Unattended Auto-Unlock

On machines with `enableLuks = true` and a hardware TPM 2.0 (such as ThinkCentre M920q/M720q or Beelink EQR5):

1. Install the node via `solar-install` and set a recovery passphrase when prompted.
1. On first boot into NixOS, seal the encryption key to the hardware TPM:
   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
   ```
1. Test unattended reboot:
   ```bash
   sudo reboot
   ```
   The machine unlocks and boots without any manual passphrase entry.

### Persisting New Directories on Ephemeral Nodes

When running with `usePersistence = true`, unmanaged state disappears on reboot. To persist a file or directory:

- In your host configuration or module:
  ```nix
  myFeatures.core.system.preservation.preserveAt = [
    {
      directory = ".config/myapp";
      user = "yourusername";
      group = "users";
      mode = "0700";
    }
  ];
  ```
- Or place state directly in `/persist/home/yourusername/` and symlink to `~`.

______________________________________________________________________

## 🌲 Adding Custom Features (Dendritic Autodiscovery)

You never have to manually import new modules in `flake.nix`.

The dendritic autoscanner (`modules/default.nix`) recursively inspects the filesystem and converts file paths into typed toggle options:

- Place a file at `modules/programs/terminal/alacritty.nix`.
- It automatically creates the option `myFeatures.programs.terminal.alacritty.enable`.
- In any host file, toggle it with:
  ```nix
  myFeatures.programs.terminal.alacritty.enable = true;
  ```

### Standard Module Template

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.myFeatures.programs.mytool;
in
{
  options.myFeatures.programs.mytool = {
    enable = lib.mkEnableOption "My Custom Tool";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mytool ];
  };
}
```

______________________________________________________________________

## ⚒️ Daily Operations: Rebuilding, Testing & Deploying

### 1. Local Rebuilds (Workstations / Laptops)

Solar provides integration with [`nh`](https://github.com/viperML/nh) (Nix Helper) for fast, clean builds:

```bash
# Rebuild and activate on the current host:
nh os switch . -H <hostname>

# Or test configuration without setting boot entry:
nh os test . -H <hostname>

# Standard NixOS alternative:
sudo nixos-rebuild switch --flake .#<hostname>
```

### 2. Apple Silicon macOS Rebuilds (`nix-darwin`)

```bash
darwin-rebuild switch --flake .#<hostname>
```

### 3. Remote Server Deployment

Deploy changes directly across your local network or over Tailscale without logging into the target server:

```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<ip-or-hostname>
```

### 4. Dry-Run Evaluation & Flake Checks

Before committing or pushing, verify that all configurations evaluate without syntax or dependency errors:

```bash
# Fast evaluation check across the entire flake:
nix flake check --no-build

# Or evaluate a single machine:
nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath
```

______________________________________________________________________

## 🧹 Routine Maintenance & Upgrades

### Updating Flake Dependencies

Keep Nixpkgs, Home Manager, and upstream inputs up to date:

```bash
# Update all inputs:
nix flake update

# Or update only nixpkgs:
nix flake lock --update-input nixpkgs-unstable
```

### Garbage Collection & Optimizing Storage

Clean older system generations and optimize the Nix store:

```bash
# Clean generations older than 7 days:
nh clean all --keep 3

# Hardlink identical store paths:
nix-store --optimise
```

### Formatting Code

Solar enforces formatting via `treefmt`:

```bash
# Format all nix, markdown, and shell files:
treefmt
```

### Building a Fresh Live Installer ISO

To produce a bootable Solar Live USB installer:

```bash
nix build .#nixosConfigurations.installer.config.system.build.isoImage
```

The resulting `.iso` file is output to `./result/iso/`.

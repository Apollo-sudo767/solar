# Dendritic Architecture 🌲

Solar uses a **dendritic module pattern** rather than monolithic configuration files. Modules act like branches and leaves on a tree, automatically discovering themselves based on their folder structure.

______________________________________________________________________

## 🏗️ The 3-Tier System

Solar organizes configuration into three intuitive layers:

```
solar/
├── modules/
│   ├── core/         # Tier 1: Foundation (Disko, Users, Boot, Security, Nix)
│   ├── platforms/    # Tier 2: Compositors & Display Managers (Niri, SDDM, ReGreet)
│   ├── programs/     # Tier 2: User Tools (Ghostty, Helix, Browsers, Media)
│   ├── services/     # Tier 2: Daemons (Tailscale, Nginx, Syncthing, Factorio)
│   ├── suites/       # Tier 3: Workflow bundles (workstation, gaming, server)
│   └── hosts/        # Terminal Leaves: Concrete machine declarations
```

### Tier 1: Core Foundation (`modules/core/`)

Provides essential host functionality:

- **`system`**: Disko declarative storage, users, preservation, and virtualization.
- **`boot`**: UEFI Limine bootloader, kernel parameters, Secure Boot signing.
- **`security`**: AppArmor MAC profiles, kernel hardening, SSH, Agenix secrets.
- **`shell`**: Zsh, Starship prompt, Fastfetch, and core CLI utilities.
- **`nix`**: Lix package manager, automated GC, flake registry pinning.

### Tier 2: Granular Feature Leaves

Individual tools and capabilities configured with typed options:

- Located under `platforms/`, `programs/`, `services/`, and `hardware/`.
- Every feature defines an `enable = lib.mkEnableOption "..."` toggle under `myFeatures.<path>`.

### Tier 3: Functional Suites (`modules/suites/`)

Convenient bundles that activate coherent groups of Tier 2 features:

- **`suites.workstation.enable = true`**: Full graphical workstation environment (Niri, Ghostty, Firefox, Obsidian, Bitwarden, Sunshine).
- **`suites.server.enable = true`**: Headless server baseline (Fail2ban, key-only SSH, Tailscale, automated scrubs).
- **`suites.gaming.enable = true`**: Steam, Proton, Gamescope, OBS Studio, and performance governors.

______________________________________________________________________

## 🔍 The Dendritic Autoscanner (`modules/default.nix`)

Traditional Nix configs require maintaining massive `imports = [ ... ]` arrays in `flake.nix`. Solar eliminates this through automatic filesystem reflection:

```nix
# modules/default.nix
# Recursively traverses modules/ and discovers all default.nix and *.nix files
```

### How Option Paths are Generated

The path on disk maps 1:1 to the option hierarchy:

| File Location on Disk | Discovered Option Path |
| :--- | :--- |
| `modules/programs/terminal/ghostty.nix` | `myFeatures.programs.terminal.ghostty.enable` |
| `modules/services/networking/tailscale.nix` | `myFeatures.services.networking.tailscale.enable` |
| `modules/platforms/desktops/niri.nix` | `myFeatures.platforms.desktops.niri.enable` |

To add a new tool or daemon, simply drop a `.nix` file into the appropriate directory. It is immediately available across all hosts without touching `flake.nix`.

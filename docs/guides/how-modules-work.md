# How Modules Work 🌲

Solar uses a **Dendritic Module System** where every feature, service, desktop environment, and hardware driver is defined as an independent, composable NixOS/Home Manager module.

______________________________________________________________________

## 🏛️ The Module Tree & Options Hierarchy

All custom options in Solar live under the unified namespace:

```nix
config.myFeatures.<category>.<subcategory>.<feature>
```

### Module Categories

| Category | Path | Description |
| :--- | :--- | :--- |
| **`core`** | `modules/core/` | Foundational system settings: bootloaders (`limine`, `grub`, `systemd`), Nix settings (`lix`, `cachix`, `automation`), security (`agenix`, `ssh`), shell (`zsh`, `starship`, `cli`), and system management (`users`, `disko`, `preservation`). |
| **`hardware`** | `modules/hardware/` | Hardware drivers and hardware-specific toggles: CPU/GPU (`amd`, `intel`, `nvidia`, `prime`), input devices (`controllers`, `wooting`, `trackpad`), peripherals (`battery`, `bluetooth`, `wifi`), and graphics. |
| **`platforms`** | `modules/platforms/` | Graphical environments: window managers & DEs (`niri`, `kde`, `gnome`, `cosmic`), addons (`displayManager`, `noctalia`, `waybar`, `swaync`, `idle`, `swaylock`), and centralized ricing/styling (`stylix`, `themes`, `flavors`). |
| **`programs`** | `modules/programs/` | User-facing software: browsers (`firefox`, `zen`, `chrome`), terminal applications (`ghostty`, `helix`, `fastfetch`, `antigravity`, `nh`, `git`), media & gaming (`steam`, `tf2`, `mumble`, `vr`, `obs`, `davinci`, `prism`, `vlc`, `ani-cli`), office tools (`ap-office`), and utilities (`bitwarden`, `social`, `vesktop`, `filemanager`, `spotify`, `logseq`). |
| **`services`** | `modules/services/` | System daemons and background servers: multimedia (`audio`, `sunshine`), hardware utilities (`printing`, `udisks2`, `openrgb`), networking (`tailscale`, `resolved`, `syncthing`), and servers (`minecraft`, `joplin`, `trilium`, `samba`, `nfs`). |
| **`darwin`** | `modules/darwin/` | macOS-specific system modules (`homebrew`, `system defaults`, `core`). |
| **`hosts`** | `modules/hosts/` | Host definitions and hardware configurations (the terminal leaves of the dendritic tree). |

______________________________________________________________________

## 🔄 Automatic Module Discovery (`modules/default.nix`)

In conventional Nix flakes, every module file must be explicitly imported in a central list. In Solar, `modules/default.nix` implements an automated recursive filesystem scanner:

1. **Scans `modules/`**: Recursively discovers every `.nix` file (skipping `hosts/` and `default.nix`).
1. **Platform Reflection**: Inspects the function arguments of each file:
   - **`isDarwin`**: Module is loaded strictly on macOS Darwin systems (files in `modules/darwin/`).
   - **`isTotal`**: Universal module loaded on both Linux and macOS.
   - **Linux Default**: Modules without special platform arguments are automatically loaded on all Linux configurations and excluded from macOS builds.
1. **Zero-Boilerplate Addition**: When you drop a new `.nix` file into any subdirectory in `modules/`, it is immediately available across all hosts without editing an imports list.

______________________________________________________________________

## 🧩 Anatomy of a Solar Module

Each module follows a standard declarative pattern combining NixOS options, system packages, Home Manager configuration, and impermanence preservation:

```nix
{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.exampleTool;
in
{
  # 1. Define custom options under the myFeatures namespace
  options.myFeatures.programs.terminal.exampleTool = {
    enable = lib.mkEnableOption "Example CLI tool";
    extraFlag = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable extra features";
    };
  };

  # 2. Implement system configuration when the feature is enabled
  config = lib.mkIf cfg.enable {
    # System-level packages
    environment.systemPackages = [ pkgs.example-tool ];

    # Multi-user Home Manager configuration
    home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
      programs.example-tool = {
        enable = true;
        settings = {
          enable_extras = cfg.extraFlag;
        };
      };
    });

    # Impermanence preservation for stateful config directories (Linux wipe-on-boot)
    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (config.myFeatures.core.system.preservation.enable && !isDarwin) {
        users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
          directories = [
            ".config/example-tool"
            ".local/share/example-tool"
          ];
        });
      };
  };
}
```

______________________________________________________________________

## 👥 Multi-User Home Manager Generation

Rather than hardcoding single user accounts, Solar modules dynamically generate user configuration across all users configured on the system using:

```nix
home-manager.users = lib.genAttrs config.myFeatures.core.system.users.usernames (name: {
  # Per-user configuration here
});
```

This guarantees consistent dotfiles, themes, and application settings whether a host has one user or multiple users.

______________________________________________________________________

## 💾 Wipe-On-Boot & Impermanence (`preservation`)

Solar supports ephemeral root filesystems (root on tmpfs/Btrfs wiped on every reboot) via the `preservation` module.

When `config.myFeatures.core.system.core-branch.usePersistence = true;` is enabled on a host:

- System state is preserved in `/persistent` (or configured persistent path).
- Modules declare the directories and files they need to survive reboots:
  ```nix
  preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
    lib.mkIf config.myFeatures.core.system.preservation.enable {
      users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
        directories = [ ".config/gh" ".local/share/keyrings" ];
        files = [ ".zsh_history" ];
      });
    };
  ```

______________________________________________________________________

## 🎨 Centralized Styling & Theming

Styling in Solar is orchestrated through **Stylix** and custom flavor modules located in `modules/platforms/styling/`:

- **Themes**: Pre-packaged color palettes (`sky`, `gruvbox`, `strawberry`, `forest`, `space`) defined under `myFeatures.platforms.styling.themes.<name>`.
- **Flavors**: Universal composited desktop styles (e.g. `flavors.sky`, `flavors.gruvbox`) that configure window borders, rounded corners, blur effects, shell integration, and keybindings across active compositors.

______________________________________________________________________

## 🖥️ Monitor & Output Configuration in Niri

The Niri window manager module (`modules/platforms/desktops/niri/outputs.nix`) provides a declarative `monitors` list option:

```nix
myFeatures.platforms.desktops.niri.monitors = [
  {
    name = "DP-4";
    aliases = [ "ASUSTek COMPUTER INC VG27WQ3B TALMTR031961" ];
    resolution = "1440p";       # Preset: "1080p", "1440p", "4k", "720p", "ultrawide-1440p", etc.
    refresh = 180.0;            # Hz
    orientation = "horizontal"; # "horizontal", "vertical" (90°), "vertical-inverted" (270°), "inverted" (180°)
    position = { x = 0; y = 0; };
    vrr = true;                 # Variable Refresh Rate (Adaptive Sync / G-Sync / FreeSync)
  }
];
```

The module automatically resolves common resolution names into physical pixel dimensions, calculates rotation matrices for vertical/horizontal setups, and outputs clean KDL configuration for Niri.

______________________________________________________________________

## 🔐 Secrets Management with Agenix

Secrets are encrypted with Age keys and managed by **agenix** and **agenix-rekey**:

- Encrypted secrets are stored in the private secrets repository (`solar-secrets`).
- Hosts declare `useSolarSecrets = true` in their `meta` block.
- Secret files are decrypted on boot into `/run/agenix/` and referenced cleanly in system services.

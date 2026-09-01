# Frequently Asked Questions (FAQ) ❓

Answers to frequently asked questions about the architecture, workflows, and tools in Solar.

______________________________________________________________________

## 🌲 Architecture & Dendritic Modules

### Q: Why is it called a "Dendritic" configuration?

In neuroscience and botany, dendrites are branched structures that receive and relay signals to a central core. In Solar, modules act as independent branches that are automatically discovered and composed into high-level suites (`workstation`, `gaming`, `creator`, `server`), terminating in host leaves (`mars`, `mercury`, `venus`) without requiring manual centralized imports lists.

### Q: How do suites differ from regular modules?

- **Modules** are fine-grained, atomic capability switches (e.g. `programs.media.davinci`, `core.boot.secureBoot`).
- **Suites** are composite collections of complementary modules enabled using `lib.mkDefault` (e.g. `suites.creator` enables DaVinci, OBS, VLC, Ani-CLI, and media codecs together).

### Q: Why are themes and greeters not inside suites?

Aesthetic identity (Stylix themes, color schemes, wallpapers) and login greeters (ReGreet, SDDM, GDM, Cosmic-greeter) are deeply personal to each physical device. Keeping them strictly in host files ensures that enabling a suite like `suites.workstation` or `suites.desktops.niri` never overrides your preferred machine styling.

______________________________________________________________________

## 💾 Storage & Ephemeral Root

### Q: What is "wipe-on-boot" (ephemeral root)?

On hosts like **Mars** and **Mercury**, the root filesystem (`/`) is mounted in RAM (`tmpfs`) or wiped on every boot. Only directories explicitly declared in `preservation` (such as `.config`, `.local/share`, `/etc/nixos`, and `/var/log`) survive reboots on the NVMe `/persist` subvolume. This prevents filesystem rot, stale cache buildup, and accidental unmanaged state.

### Q: How do I keep a new application's state on an ephemeral host?

Declare it in the module's `preservation.preserveAt` block, or place the directory under `/persist/home/apollo/` and symlink it to your home folder.

______________________________________________________________________

## 🍏 macOS Darwin Integration

### Q: How does Solar manage both NixOS and macOS in the same flake?

`flake.nix` exports both `nixosConfigurations` (for Linux hosts) and `darwinConfigurations` (for macOS hosts like **Phobos**). The module autoscanner (`modules/default.nix`) uses platform reflection to load `modules/darwin/` and modules with `isDarwin` or `isTotal` on macOS while excluding Linux-only kernel and driver modules.

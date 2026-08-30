# Dendritic Suites Architecture 🌲

Solar features a **Dendritic Suite System** located in [`modules/suites/`](file:///Users/apollo/src/solar/modules/suites). Suites serve as composable neural branches that bundle interconnected packages, subsystems, daemons, and window manager ecosystems into high-level declarative toggles.

______________________________________________________________________

## 🎯 Why Dendritic Suites?

In traditional NixOS setups, every machine configuration often repeats dozens of lines enabling the same shell tools, audio daemons, terminal emulators, portals, and browser flags.

Solar solves this with a **3-tier dendritic hierarchy**:

```
                       ┌─────────────────────────┐
                       │   1. Domain Modules     │ (Atomic Options: programs.terminal.ghostty)
                       └────────────┬────────────┘
                                    │ (Bundled into)
                                    ▼
                       ┌─────────────────────────┐
                       │   2. Composite Suites   │ (Roles & Workflows: suites.workstation)
                       └────────────┬────────────┘
                                    │ (Activated by)
                                    ▼
                       ┌─────────────────────────┐
                       │    3. Host Leaves       │ (Machine Config: mars/default.nix)
                       └─────────────────────────┘
```

1. **Atomic Domain Modules** (`core/`, `hardware/`, `platforms/`, `programs/`, `services/`): Define fine-grained capability switches.
2. **Composite Suites** (`suites/`): Bundle 5–15 complementary domain options together using non-invasive `lib.mkDefault` values.
3. **Host Leaves** (`hosts/<name>/default.nix`): Clean declarations that activate high-level suites while maintaining 100% control over physical hardware, disks, and personal styling.

______________________________________________________________________

## 📜 The Golden Laws of Suites

To maintain architectural purity and zero side-effects across the fleet, all Solar suites adhere to three strict principles:

### 1. The `lib.mkDefault` Law
Every option set inside a suite must use `lib.mkDefault`. This ensures that any individual host leaf can override or disable any specific sub-feature (e.g. disabling a specific tool or changing a port) without encountering module conflicts.

### 2. The Styling Separation Law (Strict Host Ownership)
**No suite ever decides visual styling or login greeters.**
- Color palettes, Stylix themes (`sky`, `forest`, `strawberry`, `space`), wallpapers, and fonts are strictly host-declared.
- Display managers (`regreet`, `sddm`, `gdm`, `cosmic-greeter`) are strictly host-declared.
- This guarantees that turning on `suites.workstation` or `suites.desktops.niri` never interferes with a machine's aesthetic identity.

### 3. Cross-Platform Segregation
- Linux-exclusive suites omit `isDarwin` from their function headers so they are never imported on macOS builds.
- Dedicated Darwin suites live in `modules/darwin/suites/` (`suites.darwinWorkstation`).

______________________________________________________________________

## 🚀 Activating Suites on a Host

Activating a suite is as simple as enabling its toggle in `modules/hosts/<hostname>/default.nix`:

```nix
{
  module = { ... }: {
    myFeatures = {
      # 🌲 Composite Suites
      suites = {
        workstation.enable = true;
        gaming.enable = true;
        creator.enable = true;
        desktops.niri.enable = true;
      };

      # 🎨 Host Aesthetics (Strictly Host-Managed)
      platforms.styling = {
        stylix.enable = true;
        flavors.sky.enable = true;
      };
      platforms.addons.displayManager.manager = "regreet";
    };
  };
}
```

# Desktop Environments & Compositors 🖥️

Solar provides declarative, composable support for multiple modern Wayland desktop environments and scrollable compositors.

______________________________________________________________________

## 🌊 1. Niri (Scrollable Tiling Compositor)

**Niri** is the flagship desktop compositor for Solar workstations (**Mars** and **Mercury**). It features an infinite horizontal ribbon layout where windows are tiled onto scrollable columns.

### Key Features in Solar:

- **Declarative Monitor Resolution & Layout Engine**:
  Configured via `myFeatures.platforms.desktops.niri.monitors`:
  ```nix
  myFeatures.platforms.desktops.niri.monitors = [
    {
      name = "ASUSTek COMPUTER INC VG27WQ3B TALMTR031961";
      aliases = [ "DP-2" "DP-4" ];
      resolution = "1440p";       # Presets: "1080p", "1440p", "4k", "720p", "ultrawide-1440p"
      refresh = 180.0;            # 180Hz refresh rate
      orientation = "horizontal"; # "horizontal", "vertical", "vertical-inverted", "inverted"
      position = { x = 1080; y = 0; };
      vrr = true;                 # Adaptive Sync / FreeSync / G-Sync
      primary = true;
      focusAtStartup = true;
    }
  ];
  ```
- **Unified Keybindings**: Consistent window management, workspace navigation, application spawning, and media controls across all active themes.
- **Micro-Compositor Integration**: Native coordination with Gamescope for smooth game transitions.

______________________________________________________________________

## 🎨 2. KDE Plasma 6

**KDE Plasma 6** is the primary desktop environment for gaming rigs (**Elara** and **Europa**) and handhelds (**Amalthea**).

- **Wayland Native**: Running pure Wayland session with fractional scaling, HDR, and per-monitor color management.
- **Stylix Integration**: Automatic synchronization of color palettes, widget styles, icon sets, and SDDM greeters.
- **Gaming First**: Full support for Steam Big Picture, MangoHud overlays, and GameMode scheduler boosts.

______________________________________________________________________

## 🪟 3. GNOME

Solar includes a modern, streamlined **GNOME** desktop module with native GDM display manager integration, Wayland session support, and Stylix styling.

______________________________________________________________________

## 🚀 4. COSMIC Desktop Environment

The next-generation Rust-based desktop environment by System76, featured on the testbed machine **Io**:

- Powered by `cosmic-comp`, `cosmic-panel`, and `cosmic-applets`.
- Native **COSMIC Greeter** integration.
- Stylix color palette theming across all native iced GUI widgets.

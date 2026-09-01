# Setting Up a Basic Desktop Host 🖥️

This guide walks you through setting up a complete graphical desktop or laptop workstation in Solar—including hardware drivers, display environments, monitor layouts, and everyday applications.

______________________________________________________________________

## 🏗️ Step 1: Create Host Directory and Files

Choose a celestial name for your workstation (e.g. `mars`, `mercury`, `titan`) and create its directory under `modules/hosts/`:

```bash
mkdir -p modules/hosts/<hostname>
```

A host requires two files:

1. `modules/hosts/<hostname>/hardware-configuration.nix`
1. `modules/hosts/<hostname>/default.nix`

______________________________________________________________________

## ⚙️ Step 2: Hardware Configuration (`hardware-configuration.nix`)

Generate the hardware configuration from your machine or configure standard kernel modules:

```nix
# modules/hosts/<hostname>/hardware-configuration.nix
{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ]; # or "kvm-intel"
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware; # or hardware.cpu.intel
}
```

______________________________________________________________________

## 🎨 Step 3: Desktop Host Blueprint (`default.nix`)

Create `modules/hosts/<hostname>/default.nix`. Below is a complete, production-ready desktop workstation blueprint:

```nix
# modules/hosts/<hostname>/default.nix
{
  meta = {
    system = "x86_64-linux";
    stable = false;          # Use nixpkgs-unstable for latest drivers and desktop tools
    useSolarSecrets = true;  # Set false if running without private secrets repository
  };

  module =
    { ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      myFeatures = {
        # -------------------------------------------------------------
        # 1. 🌲 COMPOSABLE DENDRITIC SUITES
        # -------------------------------------------------------------
        suites = {
          workstation.enable = true;      # Ghostty, Helix, NH, Fastfetch, Bitwarden, Portals, Audio
          gaming.enable = true;           # Steam + Proton installer, GameScope, Controllers, Mumble, TF2
          creator.enable = true;          # DaVinci Resolve, OBS Studio, VLC, Ani-CLI, Media tools
          streaming.enable = true;        # Sunshine 48000 + Moonlight Game Streaming Host
          productivity.enable = true;     # AP-Office authoring + CUPS printing subsystem
          hardened.enable = true;         # AppArmor security profiles + Systemd OOMD daemon
          networking.enable = true;       # Tailscale mesh VPN + Resolved DNS
          desktops.niri.enable = true;    # Niri scrollable compositor + Noctalia v5 + Keybinds
        };

        # -------------------------------------------------------------
        # 2. 🎛️ CORE STORAGE, BOOTLOADER & SECRETS
        # -------------------------------------------------------------
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = true; # Wipe root on boot (ephemeral / with persistent storage)
            };
            users = {
              usernames = [ "apollo" ];
              agenixPassword = true;
            };
            disko = {
              enable = true;
              speedDisks = [ "/dev/nvme0n1" ]; # Primary fast NVMe disk for OS and home
              # bulkDisks = [ "/dev/sda" ];     # Optional secondary bulk storage disk
            };
          };
          boot = {
            enable = true;
            loader = "limine";              # Fast, modern bootloader
            secureBoot.enable = true;       # Native Secure Boot with Lanzaboote
            kernel = "zen";                 # Zen kernel optimized for low-latency desktop/gaming
          };
          security.agenix.usePrivateSecrets = true;
        };

        # -------------------------------------------------------------
        # 3. ⚙️ HARDWARE & DRIVERS
        # -------------------------------------------------------------
        hardware = {
          cpu-gpu = {
            amd.enable = true;              # AMD CPU/GPU drivers (or intel.enable = true)
            nvidia = {
              enable = true;                # Nvidia GPU support (if applicable)
              open = true;                  # Use open kernel modules (Turing+)
            };
          };
          system.ttyResolution = {
            enable = true;
            resolution = "2560x1440";       # High-resolution TTY on boot
          };
          peripherals = {
            bluetooth.gaming.enable = true;
            wifi = {
              enable = true;
              persistence = true;
            };
            # battery.fullCharge = true;    # Enable for laptops
          };
          input = {
            wooting.enable = true;          # Wooting analog keyboard support
            # trackpad.enable = true;       # Enable for laptops
          };
        };

        # -------------------------------------------------------------
        # 4. 🖥️ OUTPUT TOPOLOGY, STYLING & GREETER (Strictly Host-Managed)
        # -------------------------------------------------------------
        platforms = {
          desktops.niri = {
            modKey = "super";               # "super" or "left-alt"
            monitors = [
              {
                name = "DP-1";
                resolution = "1440p";       # "1080p", "1440p", "4k", "720p", "ultrawide-1440p"
                refresh = 180.0;            # 180Hz refresh rate
                orientation = "horizontal"; # "horizontal", "vertical", "vertical-inverted", "inverted"
                position = { x = 0; y = 0; };
                vrr = true;                 # Variable Refresh Rate (G-Sync / FreeSync)
                primary = true;
              }
              {
                name = "DP-2";
                resolution = "1080p";
                refresh = 165.0;
                orientation = "vertical";   # Secondary vertical monitor
                position = { x = 2560; y = 0; };
                vrr = true;
              }
            ];
          };
          styling = {
            stylix.enable = true;
            flavors.sky.enable = true;          # Complete Sky flavor preset
          };
          addons.displayManager.manager = "regreet"; # Modern GTK4 Wayland greeter
        };

        # -------------------------------------------------------------
        # 5. 👤 PERSONAL CREDENTIALS & SPECIALIZED APPS
        # -------------------------------------------------------------
        programs = {
          terminal.git = {
            userName = "YourName";
            userEmail = "you@example.com";
          };
          browsers.firefox = {
            nightly.enable = true;
            extensions.enable = true;
          };
          utilities.spotify.tui.enable = true;
        };
      };
    };
}
```

______________________________________________________________________

## 🖥️ Choosing an Alternative Desktop Suite

Solar provides dedicated desktop suites for all 18 major window managers and desktop environments:

### Wayland Compositor Suites

```nix
suites.desktops = {
  niri.enable = true;       # Scrollable tiling Wayland compositor
  hyprland.enable = true;   # Dynamic tiling Wayland compositor with smooth animations
  sway.enable = true;       # i3-compatible Wayland compositor
  mangowc.enable = true;    # Ultra-lightweight modern Wayland compositor
  wayfire.enable = true;    # 3D Compiz-style Wayland compositor
  labwc.enable = true;      # Openbox-inspired lightweight Wayland stacking WM
  qtile.enable = true;      # Hackable Python tiling WM
};
```

### X11 Window Manager Suites

```nix
suites.desktops = {
  i3.enable = true;         # Classic manual tiling WM
  bspwm.enable = true;      # Binary space partitioning WM
  awesome.enable = true;    # Highly configurable Lua-driven WM
  xmonad.enable = true;     # Dynamic tiling WM written in Haskell
  dwm.enable = true;        # Dynamic window manager for X
  openbox.enable = true;    # Highly configurable stacking WM
};
```

### Full Desktop Environment Suites

```nix
suites.desktops = {
  plasma.enable = true;     # KDE Plasma 6 Desktop
  gnome.enable = true;      # GNOME Desktop Environment
  cosmic.enable = true;     # Next-gen Rust-based COSMIC Desktop
  xfce.enable = true;       # Lightweight and modular XFCE Desktop
  cinnamon.enable = true;   # Elegant traditional Cinnamon Desktop
  mate.enable = true;       # Traditional MATE Desktop Environment
  lxqt.enable = true;       # Ultra-lightweight Qt Desktop
  budgie.enable = true;     # Modern and clean Budgie Desktop
};
```

______________________________________________________________________

## 🚀 Step 4: Build and Deploy

Test the configuration evaluation:

```bash
nix eval .#nixosConfigurations.<hostname>.config.system.stateVersion
```

Deploy the system locally:

```bash
nh os switch . -H <hostname>
```

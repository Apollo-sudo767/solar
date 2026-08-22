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
        # 1. CORE FOUNDATION
        # -------------------------------------------------------------
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = true; # Wipe root on boot (ephemeral / with persistent storage)
            };
            users = {
              usernames = [ "apollo" ];
              agenixPassword = true;  # Manage user password via encrypted secrets
            };
            disko = {
              enable = true;
              speedDisks = [ "/dev/nvme0n1" ]; # Primary fast NVMe disk for OS and home
              # bulkDisks = [ "/dev/sda" ];     # Optional secondary bulk storage disk
            };
          };
          shell.shell-branch.enable = true; # Zsh, Starship, and essential CLI tools
          boot = {
            enable = true;
            loader = "limine";              # Fast, modern bootloader
            secureBoot.enable = true;       # Native Secure Boot with lanzaboote
            kernel = "zen";                 # Zen kernel optimized for low-latency desktop/gaming
          };
          security = {
            security = {
              enable = true;
              useAppArmor = true;
            };
            agenix = {
              enable = true;
              usePrivateSecrets = true;
            };
          };
          nix.lix.enable = true;            # Modern, fast Lix Nix implementation
        };

        # -------------------------------------------------------------
        # 2. HARDWARE & DRIVERS
        # -------------------------------------------------------------
        hardware = {
          cpu-gpu = {
            amd.enable = true;              # AMD CPU/GPU drivers (or intel.enable = true)
            nvidia = {
              enable = true;                # Nvidia GPU support (if applicable)
              open = true;                  # Use open kernel modules (Turing+)
            };
          };
          system = {
            graphics.enable = true;
            ttyResolution = {
              enable = true;
              resolution = "2560x1440";     # High-resolution TTY on boot
            };
          };
          peripherals = {
            bluetooth = {
              enable = true;
              gaming.enable = true;
            };
            wifi = {
              enable = true;
              persistence = true;
            };
            # battery.enable = true;         # Enable for laptops
          };
          input = {
            controllers = {
              enable = true;
              xbox = true;
              nintendo = true;
            };
            wooting.enable = true;          # Wooting analog keyboard support
            # trackpad.enable = true;       # Enable for laptops
          };
        };

        # -------------------------------------------------------------
        # 3. DESKTOP ENVIRONMENT & MONITORS
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
              }
              {
                name = "DP-2";
                resolution = "1080p";
                refresh = 165.0;
                orientation = "vertical";   # Secondary vertical monitor!
                position = { x = 2560; y = 0; };
                vrr = true;
              }
            ];
          };
          styling = {
            stylix.enable = true;
            flavors.sky.enable = true;          # Complete Sky flavor preset for compositors & Noctalia
          };
          addons = {
            displayManager.manager = "regreet"; # Modern GTK4 Wayland greeter
          };
        };

        # -------------------------------------------------------------
        # 4. USER SOFTWARE & WORKSPACE
        # -------------------------------------------------------------
        programs = {
          terminal = {
            git = {
              enable = true;
              userName = "YourName";
              userEmail = "you@example.com";
            };
            ghostty.enable = true;          # GPU-accelerated terminal
            fastfetch.enable = true;
            helix.enable = true;            # Modal text editor
            antigravity.enable = true;      # AI coding assistant
            nh.enable = true;               # Modern Nix helper (`nh os switch`)
            direnv.enable = true;
            nix-ld.enable = true;           # Run unpatched dynamic binaries
          };
          browsers = {
            firefox = {
              nightly.enable = true;
              extensions.enable = true;
            };
            # zen.enable = true;            # Zen Browser alternative
          };
          media = {
            gaming.enable = true;
            steam = {
              protonInstaller.enable = true;
              gamescope = {
                enable = true;
                autoWrap = false;
              };
            };
            media.enable = true;
            obs.enable = true;
            davinci.enable = true;
            vlc.enable = true;
            ani-cli.enable = true;
          };
          utilities = {
            bitwarden.enable = true;        # Password manager
            stylePackages.enable = true;
            social.enable = true;           # Discord / Vesktop
            filemanager.enable = true;      # Thunar or Dolphin
            spotify = {
              enable = true;
              tui.enable = true;
            };
          };
          office = {
            ap-office.enable = true;        # Office document suite
          };
        };

        # -------------------------------------------------------------
        # 5. SYSTEM SERVICES
        # -------------------------------------------------------------
        services = {
          multimedia = {
            audio.enable = true;            # PipeWire audio stack
            sunshine = {
              enable = true;                # Moonlight game streaming host
              port = 48000;
            };
          };
          system = {
            flatpak.enable = true;
            xdgPortals.enable = true;       # Wayland screen-sharing & open dialogs
          };
          hardware = {
            printing.enable = true;         # CUPS printing daemon
            udisks2.enable = true;          # Automatic USB mounting
          };
          networking = {
            enable = true;
            resolved.enable = true;
            tailscale.enable = true;        # Mesh VPN
          };
        };
      };
    };
}
```

______________________________________________________________________

## 🖥️ Choosing an Alternative Desktop Environment

If you prefer KDE Plasma, GNOME, or COSMIC instead of Niri:

### KDE Plasma 6

```nix
platforms = {
  desktops.kde.enable = true;
  addons.displayManager.manager = "sddm";
  styling = {
    stylix.enable = true;
    themes.strawberry.enable = true;
  };
};
```

### GNOME

```nix
platforms = {
  desktops.gnome.enable = true;
  addons.displayManager.manager = "gdm";
};
```

### COSMIC Desktop

```nix
platforms = {
  desktops.cosmic.enable = true;
  addons.displayManager.manager = "cosmic-greeter";
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

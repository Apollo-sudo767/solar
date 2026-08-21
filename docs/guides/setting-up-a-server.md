# Setting Up a Basic Server Host 🖧

This guide walks you through setting up a headless, high-performance server in Solar—such as a home lab storage node, application host, or dedicated game server (like the Jupiter Moon stack: *Callisto*, *Ganymede*, *Europa*).

______________________________________________________________________

## 🎯 Headless Server Philosophy in Solar

Servers in Solar are designed to be:

- **Lightweight & Headless**: No display managers, X11/Wayland compositors, or GUI applications running in the background.
- **Hardened by Default**: SSH key-only authentication, Fail2ban brute-force protection, and strict firewall policies.
- **Mesh-Connected**: Instant, secure access via **Tailscale** private networking without exposing ports to the public internet.
- **Storage-Optimized**: Declarative multi-disk partitioning with Disko, Btrfs subvolumes, and automated maintenance scrubbing.

______________________________________________________________________

## 🏗️ Step 1: Create Host Directory

Create your server directory under `modules/hosts/`:

```bash
mkdir -p modules/hosts/<hostname>
```

______________________________________________________________________

## ⚙️ Step 2: Hardware Configuration (`hardware-configuration.nix`)

Include drivers for your server hardware (Intel/AMD CPU, RAID controllers, Ethernet NICs):

```nix
# modules/hosts/<hostname>/hardware-configuration.nix
{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../shared/hardware.nix
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" "e1000e" "igb" "r8169" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # or "kvm-amd"
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
```

______________________________________________________________________

## 🛠️ Step 3: Server Host Blueprint (`default.nix`)

Create `modules/hosts/<hostname>/default.nix`. Below is a complete, production-grade server blueprint:

```nix
# modules/hosts/<hostname>/default.nix
{
  meta = {
    system = "x86_64-linux";
    stable = false;          # Set true for nixpkgs-stable if high stability is required
    useSolarSecrets = true;  # Enables agenix secrets for SSH keys and service tokens
  };

  module =
    { config, lib, pkgs, ... }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      myFeatures = {
        # -------------------------------------------------------------
        # 1. HEADLESS CORE FOUNDATION
        # -------------------------------------------------------------
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = false; # Set true for impermanence / ephemeral root
            };
            users = {
              usernames = [ "apollo" ];
              agenixPassword = true;
            };
            disko = {
              enable = true;
              enableLuks = true;       # Enable LUKS encryption on primary disks
              speedDisks = [ "/dev/nvme0n1" ]; # High-speed NVMe for OS & databases
              bulkDisks = [            # Storage pool drives for media / backups
                "/dev/sda"
                "/dev/sdb"
              ];
            };
          };
          shell = {
            shell-branch.enable = true; # Zsh, Starship prompt, and CLI toolkit
            cli.enable = true;
          };
          boot = {
            enable = true;
            loader = "limine";        # Modern, reliable bootloader
            kernel = "latest";        # Latest LTS/stable kernel for broad hardware support
            secureBoot.enable = false; # Optional: enable if motherboard supports enrolled keys
          };
          security = {
            security = {
              enable = true;
              useAppArmor = true;
              useOOMD = true;         # Protect against out-of-memory lockups
            };
            ssh.enable = true;
            agenix = {
              enable = true;
              usePrivateSecrets = true;
            };
            nix = {
              lix.enable = true;
              automation.enable = true; # Automated daily garbage collection
            };
          };
        };

        # -------------------------------------------------------------
        # 2. HARDWARE & POWER
        # -------------------------------------------------------------
        hardware = {
          cpu-gpu.intel.enable = true;  # Intel QuickSync / hardware transcoding
          peripherals.bluetooth.enable = false; # Disabled on headless servers to save resources
          peripherals.wifi.enable = false;      # Prefer wired Ethernet on servers
        };

        # -------------------------------------------------------------
        # 3. ESSENTIAL SERVER UTILITIES
        # -------------------------------------------------------------
        programs = {
          terminal = {
            ghostty.enable = false;    # No GUI terminal needed
            helix.enable = true;       # Fast terminal editor
            fastfetch.enable = true;
            nh.enable = true;          # CLI management helper
            direnv.enable = true;
            nix-ld.enable = true;      # Run dynamic binaries without patching
          };
        };

        # -------------------------------------------------------------
        # 4. SERVER SERVICES & DAEMONS
        # -------------------------------------------------------------
        services = {
          # Storage & Hardware Monitoring
          hardware = {
            udisks2.enable = true;
          };

          # Networking & Remote Access
          networking = {
            enable = true;
            tailscale.enable = true;   # Private WireGuard mesh access
            resolved.enable = true;
          };

          # Application Workloads
          servers = {
            # Minecraft Dedicated Server (via nix-minecraft)
            minecraft = {
              enable = true;
              eula = true;
              openFirewall = true;
            };

            # Joplin Sync Server / Note Syncing
            joplin = {
              enable = false;
              port = 22300;
            };

            # Samba / SMB Network File Shares
            samba = {
              enable = true;
              shares = {
                storage = {
                  path = "/storage/bulk";
                  browseable = "yes";
                  "read only" = "no";
                  "guest ok" = "no";
                };
              };
            };

            # NFS Exports
            nfs = {
              enable = false;
            };
          };
        };
      };

      # -------------------------------------------------------------
      # 5. SERVER SECURITY HARDENING & FIREWALL
      # -------------------------------------------------------------
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = lib.mkDefault "prohibit-password";
          PasswordAuthentication = lib.mkDefault false; # Key-only SSH access
          KbdInteractiveAuthentication = false;
        };
      };

      services.fail2ban = {
        enable = true;
        maxretry = 5;
        bantime = "24h";
      };

      networking.firewall = {
        enable = true;
        allowPing = true;
        trustedInterfaces = [ "tailscale0" ]; # Full access over private Tailscale VPN
        allowedTCPPorts = [ 22 ];             # Open SSH port (or access only via Tailscale)
      };

      # Automated Weekly Storage Scrubbing (Btrfs)
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = [ "/" "/storage/bulk" ];
      };
    };
}
```

______________________________________________________________________

## 🔒 Step 4: Connecting Securely via Tailscale

With Tailscale enabled, you don't need to forward ports on your home router:

1. Deploy the server configuration.
1. Authenticate the server on your Tailscale tailnet:
   ```bash
   sudo tailscale up --ssh
   ```
1. Connect from your laptop or workstation from anywhere in the world:
   ```bash
   ssh apollo@<hostname>
   ```

______________________________________________________________________

## 📈 Step 5: Adding Custom Background Services

To add custom background daemons (e.g. Docker, Podman, web services), you can enable them directly in your server configuration:

```nix
# Enable Podman / Docker Virtualization
myFeatures.core.system.virtualization = {
  enable = true;
  podman = true;
};
```

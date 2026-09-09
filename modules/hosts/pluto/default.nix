{
  meta = {
    system = "x86_64-linux";
    stable = false;
    useSolarSecrets = true;
  };

  module =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        ./hardware-configuration.nix
      ];

      system.stateVersion = "26.11";

      # Pluto: Beelink EQR5 (Ryzen 7 5825U, 32GB RAM) - K3s Bootstrap Master (HA Node 1)
      myFeatures = {
        # 🌲 Dendritic Suites
        suites.server.enable = true;

        # 🎛️ Host & Storage Specifics
        core = {
          system = {
            core-branch = {
              enable = true;
              usePersistence = true;
            };
            disko = {
              enable = true;
              enableLuks = false;
              speedDisks = [ "/dev/nvme0n1" ];
            };
            users = {
              usernames = [ "apollo" ];
              agenixPassword = true;
            };
          };
          boot = {
            enable = true;
            loader = "limine";
            kernel = "latest";
            secureBoot.enable = false;
          };
          security = {
            security.useAppArmor = true;
            security.useOOMD = true;
            agenix = {
              enable = true;
              usePrivateSecrets = true;
            };
          };
        };

        hardware = {
          cpu-gpu.amd.enable = true;
          peripherals = {
            bluetooth.enable = false;
            wifi = {
              enable = true;
              persistence = true;
            };
          };
        };
      };

      # Wake on LAN across ethernet interfaces
      networking.interfaces = {
        eno1.wakeOnLan.enable = true;
        eth0.wakeOnLan.enable = true;
      };

      # Kernel hardware watchdog timers for auto-recovery on system freezes
      services.watchdog.enable = true;

      # --- K3s HA Multi-Master Configuration (Bootstrap Master) ---
      myFeatures.services.k3s.secretSync.enable = true;

      services.k3s = {
        enable = true;
        role = "server";
        clusterInit = true; # Initializes the embedded etcd HA cluster
        tokenFile =
          if (config.age.secrets ? "k3s-token.age") then
            config.age.secrets."k3s-token.age".path
          else
            lib.mkDefault "/persist/etc/rancher/k3s/cluster-token";
        extraFlags = "--disable traefik --disable local-storage --flannel-backend=vxlan --node-name=pluto --node-label node.type=compute";
      };

      # Ensure cluster token directory exists on boot
      systemd.tmpfiles.rules = [
        "d /persist/etc/rancher/k3s 0700 root root - -"
      ];

      # Preserve k3s state across wipe-on-boot ephemeral root
      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" = {
        directories = [
          "/var/lib/rancher"
          "/etc/rancher"
        ];
      };

      # --- Staggered Maintenance & Automated Weekly Reboots (Slot 1: Sunday 03:00) ---
      system.autoUpgrade = {
        enable = true;
        dates = "Sun 03:00";
        allowReboot = true;
        rebootWindow = {
          lower = "03:00";
          upper = "03:20";
        };
        flake = "github:Apollo-sudo767/solar";
      };

      systemd.timers.weekly-cluster-reboot = {
        description = "Weekly staggered cluster reboot timer (Pluto @ Sun 03:00)";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "Sun 03:00";
          Persistent = true;
        };
      };

      systemd.services.weekly-cluster-reboot = {
        description = "Weekly staggered cluster reboot service";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemctl reboot";
        };
      };

      # Firewall & k3s cluster networking
      services.fail2ban.enable = true;
      networking.firewall = {
        enable = lib.mkDefault true;
        allowedTCPPorts = [
          22 # SSH
          6443 # k3s API Server
          2379 # k3s etcd client
          2380 # k3s etcd peer
          10250 # Kubelet metrics
        ];
        allowedUDPPorts = [
          8472 # Flannel VXLAN overlay network
        ];
      };

      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault true;
      };
    };
}

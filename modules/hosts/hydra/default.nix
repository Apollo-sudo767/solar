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

      # Hydra: Lenovo ThinkCentre M920q Tiny (16GB RAM) - K3s HA Control-Plane Master (Node 3)
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
          cpu-gpu.intel.enable = true;
          peripherals = {
            bluetooth.enable = false;
            wifi = {
              enable = true;
              persistence = true;
            };
          };
        };
      };

      # --- K3s HA Multi-Master Configuration (Joining Master 3) ---
      services.k3s = {
        enable = true;
        role = "server"; # Master node participating in etcd quorum
        serverAddr = "https://pluto:6443";
        tokenFile = lib.mkDefault "/persist/etc/rancher/k3s/cluster-token";
        extraFlags = "--disable traefik --flannel-backend=vxlan --node-name=hydra";
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

      # --- Staggered Maintenance & Automated Weekly Reboots (Slot 3: Sunday 04:00) ---
      system.autoUpgrade = {
        enable = true;
        dates = "Sun 04:00";
        allowReboot = true;
        rebootWindow = {
          lower = "04:00";
          upper = "04:20";
        };
        flake = "github:Apollo-sudo767/solar";
      };

      systemd.timers.weekly-cluster-reboot = {
        description = "Weekly staggered cluster reboot timer (Hydra @ Sun 04:00)";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "Sun 04:00";
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

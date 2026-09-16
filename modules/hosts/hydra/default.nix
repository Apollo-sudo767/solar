{
  meta = {
    system = "x86_64-linux";
    stable = true;
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

      system.stateVersion = "26.05";

      # Hydra: Lenovo ThinkCentre M920q Tiny (i5-8500T, 24GB RAM) - K3s HA Control-Plane Master (Node 3)
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
              enableLuks = true;
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
            secureBoot.enable = true;
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

      # --- Intel GPU & QuickSync Configuration ---
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver # iHD driver for Gen 9+ (i5-8500T UHD 630)
          intel-vaapi-driver # i965 fallback
          libvdpau-va-gl
          intel-compute-runtime # OpenCL support
        ];
      };

      # Ensure permissions for containerized Intel QuickSync access (/dev/dri)
      users.users.apollo.extraGroups = [
        "video"
        "render"
      ];

      services.udev.extraRules = ''
        KERNEL=="renderD*", GROUP="render", MODE="0666"
        KERNEL=="card*", GROUP="video", MODE="0666"
      '';

      # Wake on LAN across ethernet interfaces
      networking.interfaces = {
        eno1.wakeOnLan.enable = true;
        eth0.wakeOnLan.enable = true;
      };

      # Kernel hardware watchdog timers for auto-recovery on system freezes
      services.watchdog.enable = true;

      # --- K3s HA Multi-Master Configuration (Bootstrap Master Node) ---
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
        extraFlags = "--disable traefik --disable local-storage --flannel-backend=vxlan --node-name=hydra --node-label gpu.vendor=intel";
      };

      # Support NFS mounting
      boot.supportedFilesystems = [ "nfs" ];

      # --- Temporary Cluster NFS Server (Until Sol NAS is built) ---
      services.nfs.server = {
        enable = true;
        exports = ''
          /persist/kubernetes/storage *(rw,sync,no_subtree_check,no_root_squash)
          /persist/k3s-volumes *(rw,sync,no_subtree_check,no_root_squash)
        '';
      };

      # --- Open-iSCSI & Storage Prerequisites (Longhorn HA Storage) ---
      services.openiscsi = {
        enable = true;
        name = "iqn.2020-08.org.linux-iscsi.${config.networking.hostName}:initiator";
      };

      environment.systemPackages = with pkgs; [
        nfs-utils
        util-linux
        e2fsprogs
        xfsprogs
      ];

      # Unified /persist/kubernetes storage layout (easy rsync migration when Sol NAS is ready)
      systemd.tmpfiles.rules = [
        "d /persist/etc/rancher/k3s 0700 root root - -"
        "d /persist/kubernetes 0755 root root - -"
        "d /persist/kubernetes/storage 0777 root root - -"
        "d /persist/kubernetes/longhorn 0777 root root - -"
        "L+ /persist/k3s-volumes - - - - /persist/kubernetes/storage"
      ];

      # Preserve k3s and storage state across wipe-on-boot ephemeral root
      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" = {
        directories = [
          "/var/lib/rancher"
          "/etc/rancher"
          "/var/lib/longhorn"
          "/etc/iscsi"
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
          2049 # NFS Server
          6443 # k3s API Server
          2379 # k3s etcd client
          2380 # k3s etcd peer
          10250 # Kubelet metrics
        ];
        allowedUDPPorts = [
          2049 # NFS Server
          8472 # Flannel VXLAN overlay network
        ];
      };

      services.openssh.settings = {
        PermitRootLogin = lib.mkDefault "prohibit-password";
        PasswordAuthentication = lib.mkDefault true;
      };
    };
}

# modules/hosts/hydra/default.nix
# ==============================================================================
# Host Configuration — Hydra (Lenovo ThinkCentre M920q Tiny, i5-8500T, 24GB RAM)
# ==============================================================================
# K3s HA Control-Plane Bootstrap Master (Node 3) with Intel QuickSync GPU
# pass-through, Longhorn iSCSI storage, temporary NFS export, and staggered
# weekly maintenance (Sunday 04:00).
# ==============================================================================

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
            wifi.enable = true;
          };
        };
        services = {
          networking.resolved.enable = true;
        };
      };

      # --- Intel GPU & QuickSync OpenCL Support ---
      # Note: `intel-media-driver`, `intel-vaapi-driver`, and `libvdpau-va-gl`
      # are already provided by `myFeatures.hardware.cpu-gpu.intel` and `graphics`.
      hardware.graphics.extraPackages = with pkgs; [
        intel-compute-runtime # OpenCL support
      ];

      # Ensure permissions for containerized Intel QuickSync access (/dev/dri)
      # (`video` group is already assigned by `myFeatures.core.system.users`)
      users.users.apollo.extraGroups = [
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
      myFeatures.services.hardware.watchdog.enable = true;

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
        extraFlags = "--disable traefik --disable local-storage --flannel-backend=vxlan --node-name=hydra --node-label gpu.vendor=intel --flannel-iface=eth0";
      };

      # Support NFS mounting
      boot.supportedFilesystems = [ "nfs" ];

      # --- Temporary Cluster NFS Server (Until Sol NAS is built) ---
      services.nfs.server = {
        enable = true;
        exports = ''
          /persist/kubernetes/storage *(rw,sync,no_subtree_check,no_root_squash)
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

      # Ensure Limine installs directly to the standard UEFI fallback path (/EFI/BOOT/BOOTX64.EFI)
      # on Lenovo ThinkCentre hardware, guaranteeing the binary booted by the firmware always
      # matches the enrolled config BLAKE2B hash and sbctl signature across rebuilds.
      boot.loader.limine.efiInstallAsRemovable = true;

      # Firewall & k3s cluster networking
      services.fail2ban = {
        enable = true;
        ignoreIP = [
          "127.0.0.1/8"
          "::1"
          "192.168.0.0/24"
          "100.64.0.0/10"
        ];
      };
      networking.firewall = {
        trustedInterfaces = [
          "cni0"
          "flannel.1"
        ];
        checkReversePath = "loose";
        allowedTCPPorts = [
          22 # SSH
          111 # NFS RPC portmapper
          2049 # NFS Server
          20048 # NFS mountd
          6443 # k3s API Server
          7881 # MatrixRTC LiveKit WebRTC TCP
          2379 # k3s etcd client
          2380 # k3s etcd peer
          10250 # Kubelet metrics
          30046 # Headlamp Dashboard (NodePort / Tailscale)
        ];
        allowedUDPPorts = [
          111 # NFS RPC portmapper
          2049 # NFS Server
          20048 # NFS mountd
          7882 # MatrixRTC LiveKit WebRTC UDP Mux
          8472 # Flannel VXLAN overlay network
        ];
      };
    };
}

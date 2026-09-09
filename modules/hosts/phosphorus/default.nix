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

      # Phosphorus: Repurposed Intel Hardware (16GB RAM) - k3s Cluster Node
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

      # Preserve k3s state across wipe-on-boot ephemeral root
      preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" = {
        directories = [
          "/var/lib/rancher"
          "/etc/rancher"
        ];
      };

      # --- Repurposed Laptop Server Settings ---
      # 1. Prevent node from sleeping when lid is closed
      services.logind.settings.Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
        LidSwitchIgnoreInhibited = "no";
      };

      # 2. Battery Conservation: Cap charge at 50% to prevent degradation when plugged in 24/7
      systemd.services.battery-charge-limit = {
        description = "Cap battery charge threshold at 50% to prevent battery degradation";
        after = [ "multi-user.target" ];
        wantedBy = [
          "multi-user.target"
          "post-resume.target"
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "cap-battery-50" ''
            for bat in /sys/class/power_supply/BAT* /sys/class/power_supply/battery; do
              [ -d "$bat" ] || continue
              if [ -f "$bat/charge_control_end_threshold" ]; then
                echo 50 > "$bat/charge_control_end_threshold" 2>/dev/null || true
              fi
              if [ -f "$bat/charge_control_start_threshold" ]; then
                echo 45 > "$bat/charge_control_start_threshold" 2>/dev/null || true
              fi
              if [ -f "$bat/charge_stop_threshold" ]; then
                echo 50 > "$bat/charge_stop_threshold" 2>/dev/null || true
              fi
              if [ -f "$bat/charge_start_threshold" ]; then
                echo 45 > "$bat/charge_start_threshold" 2>/dev/null || true
              fi
            done
          '';
        };
      };

      # Re-apply battery threshold whenever AC power status changes
      services.udev.extraRules = ''
        SUBSYSTEM=="power_supply", ACTION=="change", RUN+="${pkgs.writeShellScript "cap-battery-udev" ''
          for bat in /sys/class/power_supply/BAT* /sys/class/power_supply/battery; do
            [ -d "$bat" ] || continue
            [ -f "$bat/charge_control_end_threshold" ] && echo 50 > "$bat/charge_control_end_threshold" 2>/dev/null || true
            [ -f "$bat/charge_stop_threshold" ] && echo 50 > "$bat/charge_stop_threshold" 2>/dev/null || true
          done
        ''}"
      '';

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

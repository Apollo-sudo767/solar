{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.programs.media.vr;
  usernames = config.myFeatures.core.system.users.usernames;

  alvrQuestWiredScript = pkgs.writeShellScriptBin "alvr-quest-wired" ''
    set -euo pipefail
    echo "========================================="
    echo " 🎮 Oculus Quest 1 Wired ALVR Connector "
    echo "========================================="
    echo "Waiting for Quest headset via USB ADB..."
    ${pkgs.android-tools}/bin/adb wait-for-device
    echo "Setting up ADB reverse port forwarding for ALVR..."
    ${pkgs.android-tools}/bin/adb reverse tcp:9943 tcp:9943
    ${pkgs.android-tools}/bin/adb reverse tcp:9944 tcp:9944
    ${pkgs.android-tools}/bin/adb reverse udp:9944 udp:9944
    echo "Port forwarding active!"
    echo "Starting ALVR Dashboard..."
    exec ${pkgs.alvr}/bin/alvr_dashboard "$@"
  '';

  wivrnQuestWiredScript = pkgs.writeShellScriptBin "wivrn-quest-wired" ''
    set -euo pipefail
    echo "========================================="
    echo " 🎮 Oculus Quest Wired WiVRn Connector  "
    echo "========================================="
    echo "Waiting for Quest headset via USB ADB..."
    ${pkgs.android-tools}/bin/adb wait-for-device
    echo "Setting up ADB reverse port forwarding for WiVRn..."
    ${pkgs.android-tools}/bin/adb reverse tcp:9757 tcp:9757
    echo "Port forwarding active for WiVRn (port 9757)!"
  '';
in
{
  options.myFeatures.programs.media.vr = {
    enable = lib.mkEnableOption "Unified VR (Virtual Reality) Suite";

    quest = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.wireless.enable;
        description = "Enable support for Meta Quest headsets (Quest 1, 2, 3, Pro)";
      };
      wired = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Quest 1/2/3 wired ALVR/WiVRn streaming over USB (ADB reverse connection)";
      };
    };

    wireless = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable support for Wireless/Standalone headsets (Quest, Pico, Vision Pro)";
      };
    };

    wired = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable support for Wired headsets (Valve Index, Vive, Rift, WMR)";
      };
    };

    streamer = lib.mkOption {
      type = lib.types.enum [
        "wivrn"
        "alvr"
        "none"
      ];
      default = "wivrn";
      description = "Primary VR streaming provider for Quest / wireless headsets (WiVRn or ALVR)";
    };

    alvr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.streamer == "alvr";
        description = "Enable ALVR Air Light VR Streamer";
      };
    };

    wivrn = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.streamer == "wivrn";
        description = "Enable WiVRn OpenXR Streaming Server";
      };
    };

    monado = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.wired.enable;
        description = "Enable Monado OpenXR Runtime Service";
      };
    };

    sidequest = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.quest.enable;
        description = "Enable SideQuest VR App Manager";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # Ensure Steam & SteamVR are enabled
        myFeatures.programs.media.steam.enable = lib.mkDefault true;

        # System packages for VR
        environment.systemPackages =
          with pkgs;
          [
            openxr-loader
          ]
          ++ lib.optionals cfg.wivrn.enable [
            xrizer
            wivrnQuestWiredScript
          ]
          ++ lib.optionals cfg.sidequest.enable [ sidequest ]
          ++ lib.optionals (cfg.wireless.enable || cfg.quest.enable) [ android-tools ]
          ++ lib.optionals (cfg.alvr.enable && cfg.quest.wired) [ alvrQuestWiredScript ]
          ++ lib.optionals cfg.wired.enable [ libsurvive ];
      }

      # Quest & Wireless VR setup (ALVR + WiVRn + ADB)
      (lib.mkIf (cfg.wireless.enable || cfg.quest.enable) {
        users.groups.adbusers = { };
        users.users = lib.genAttrs usernames (_name: {
          extraGroups = [ "adbusers" ];
        });

        networking.firewall = {
          allowedTCPPorts = [ 5555 ];
          allowedUDPPorts = [ 5555 ];
        };
      })

      # ALVR Configuration
      (lib.mkIf cfg.alvr.enable {
        programs.alvr = {
          enable = true;
          openFirewall = true;
        };
      })

      # WiVRn Configuration
      (lib.mkIf cfg.wivrn.enable {
        services.wivrn = {
          enable = true;
          openFirewall = true;
          autoStart = true;
          highPriority = true;
          steam = {
            enable = true;
            importOXRRuntimes = true;
          };
        };

        # Disable standalone Monado service when WiVRn is enabled to avoid runtime socket conflicts
        services.monado.enable = lib.mkForce false;

        # Place OpenXR manifests into /etc/openxr/1/ so Steam Pressure Vessel / Proton containers discover WiVRn
        environment.etc."openxr/1/active_runtime.json".source =
          "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
        environment.etc."openxr/1/openxr_wivrn.json".source =
          "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";

        environment.sessionVariables = {
          PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES = "1";
          XR_RUNTIME_JSON = "/etc/openxr/1/active_runtime.json";
        };

        systemd.user.services.wivrn-quest-wired = lib.mkIf cfg.quest.wired {
          description = "WiVRn ADB Reverse Port Forwarding for Wired Quest";
          wantedBy = [ "default.target" ];
          after = [ "wivrn.service" ];
          serviceConfig = {
            Type = "simple";
            Restart = "always";
            RestartSec = "5s";
            ExecStart = "${pkgs.writeShellScript "wivrn-adb-reverse-loop" ''
              while true; do
                ${pkgs.android-tools}/bin/adb wait-for-device 2>/dev/null || sleep 3
                ${pkgs.android-tools}/bin/adb reverse tcp:9757 tcp:9757 2>/dev/null || true
                sleep 10
              done
            ''}";
          };
        };

        systemd.user.services.wivrn-openvr-config = {
          description = "Configure OpenXR and OpenVR runtime paths for WiVRn + xrizer";
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScript "setup-wivrn-openvr" ''
              mkdir -p ~/.config/openxr/1
              ln -sf /run/current-system/sw/share/openxr/1/openxr_wivrn.json ~/.config/openxr/1/active_runtime.json

              mkdir -p ~/.config/openvr
              if [ -f ~/.config/openvr/openvrpaths.vrpath ]; then
                ${pkgs.jq}/bin/jq \
                  --arg xrizer "${pkgs.xrizer}/lib/xrizer" \
                  '.runtime = ([$xrizer] + ((.runtime // []) | map(select(. != $xrizer))))' \
                  ~/.config/openvr/openvrpaths.vrpath > ~/.config/openvr/openvrpaths.vrpath.tmp \
                  && mv ~/.config/openvr/openvrpaths.vrpath.tmp ~/.config/openvr/openvrpaths.vrpath
              else
                cat <<EOF > ~/.config/openvr/openvrpaths.vrpath
              {
                "config": [ "$HOME/.local/share/Steam/config" ],
                "external_drivers": null,
                "jsonid": "vrpathreg",
                "log": [ "$HOME/.local/share/Steam/logs" ],
                "runtime": [
                  "${pkgs.xrizer}/lib/xrizer"
                ],
                "version": 1
              }
              EOF
              fi
            ''}";
          };
        };
      })

      # Monado OpenXR Service
      (lib.mkIf (cfg.monado.enable && !cfg.wivrn.enable) {
        services.monado = {
          enable = true;
          defaultRuntime = true;
          highPriority = true;
        };
      })

      # Wired Steam Hardware udev rules
      (lib.mkIf cfg.wired.enable {
        hardware.steam-hardware.enable = true;
      })

      # Preservation rules for impermanent systems
      (lib.mkIf config.myFeatures.core.system.preservation.enable {
        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" = {
          users = lib.genAttrs usernames (_name: {
            directories = [
              ".config/alvr"
              ".local/share/alvr"
              ".config/openxr"
              ".config/wivrn"
              ".local/share/monado"
            ]
            ++ lib.optionals cfg.sidequest.enable [ ".config/SideQuest" ];
            files = [
              ".config/openvr/openvrpaths.vrpath"
            ];
          });
        };
      })
    ]
  );
}

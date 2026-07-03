{
  config,
  lib,
  pkgs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.services.multimedia.sunshine;
  hasNvidia = !isDarwin && (config.myFeatures.hardware.cpu-gpu.nvidia.enable or false);
  sunshinePkg =
    if hasNvidia then
      (pkgs.sunshine.override {
        cudaSupport = true;
      })
    else
      pkgs.sunshine;
in
{
  options.myFeatures.services.multimedia.sunshine = {
    enable = lib.mkEnableOption "Sunshine: Open-source GameStream host";
    port = lib.mkOption {
      type = lib.types.port;
      default = 47990;
      description = "The port for the Sunshine Web UI";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Cross-platform safe part
      {
        environment.systemPackages = [
          sunshinePkg
          pkgs.miniupnpc
        ];
      }

      # Linux-only part: HIDDEN from macOS evaluator to prevent 'boot' errors
      (lib.optionalAttrs (!isDarwin) {
        services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = true;
          openFirewall = false;
          package = sunshinePkg;
          settings = {
            port = cfg.port - 1;
          };
          applications = {
            apps = [
              {
                name = "Desktop";
                image-path = "desktop.png";
              }
            ]
            ++
              lib.optionals
                (
                  config.myFeatures.programs.media.steam.enable or false
                  && config.myFeatures.programs.media.steam.gamescope.enable or false
                )
                [
                  {
                    name = "Steam (Gamescope)";
                    cmd = "gamescope-run steam -gamepadui";
                  }
                ];
          };
        };

        networking.firewall =
          let
            basePort = cfg.port - 1;
          in
          {
            allowedTCPPorts = [
              (basePort - 5) # Sunshine discovery / control port (default 47984)
              basePort # Sunshine base port (default 47989)
              cfg.port # Sunshine Web UI port (default 47990)
              (basePort + 21) # Sunshine RTSP port (default 48010)
            ];
            allowedUDPPorts = [
              1900 # SSDP (discovery)
              5353 # mDNS (discovery)
              (basePort + 21) # Sunshine RTSP port (default 48010)
            ];
            allowedUDPPortRanges = [
              {
                from = basePort + 9;
                to = basePort + 11; # Sunshine stream ports (default 47998-48000)
              }
              {
                from = 8000;
                to = 8010;
              }
            ];
          };

        boot.kernelModules = [ "uinput" ];
        hardware.uinput.enable = true;
        users.users.${config.myFeatures.core.system.users.mainUser}.extraGroups = [
          "uinput"
          "input"
          "render"
        ];

        environment.systemPackages = [
          pkgs.vpl-gpu-rt
        ]
        ++
          lib.optionals
            (
              config.myFeatures.programs.media.steam.enable or false
              && config.myFeatures.programs.media.steam.gamescope.enable or false
            )
            [
              (pkgs.writeShellScriptBin "gamescope-run" ''
                export ENABLE_GAMESCOPE_WSI=0
                exec ${pkgs.gamescope}/bin/gamescope -W 1920 -H 1080 -r 60 -f -- "$@"
              '')
            ];

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = lib.concatMap (name: [
                "/home/${name}/.config/sunshine"
              ]) config.myFeatures.core.system.users.usernames;
            };

        services.avahi = {
          enable = true;
          publish = {
            enable = true;
            userServices = true;
          };
        };
      })
    ]
  );
}

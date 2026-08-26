{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.myFeatures.platforms.desktops.niri;

  commonResolutions = {
    # 16:9 Standard Resolutions
    "720p" = {
      width = 1280;
      height = 720;
    };
    "hd" = {
      width = 1280;
      height = 720;
    };
    "900p" = {
      width = 1600;
      height = 900;
    };
    "1080p" = {
      width = 1920;
      height = 1080;
    };
    "fhd" = {
      width = 1920;
      height = 1080;
    };
    "1440p" = {
      width = 2560;
      height = 1440;
    };
    "2k" = {
      width = 2560;
      height = 1440;
    };
    "qhd" = {
      width = 2560;
      height = 1440;
    };
    "4k" = {
      width = 3840;
      height = 2160;
    };
    "uhd" = {
      width = 3840;
      height = 2160;
    };
    "5k" = {
      width = 5120;
      height = 2880;
    };
    "8k" = {
      width = 7680;
      height = 4320;
    };

    # 16:10 Resolutions & Handhelds
    "800p" = {
      width = 1280;
      height = 800;
    };
    "steam-deck" = {
      width = 1280;
      height = 800;
    };
    "1200p" = {
      width = 1920;
      height = 1200;
    };
    "wuxga" = {
      width = 1920;
      height = 1200;
    };
    "1600p" = {
      width = 2560;
      height = 1600;
    };
    "wqxga" = {
      width = 2560;
      height = 1600;
    };

    # Ultrawide 21:9 & 21:10 Resolutions
    "ultrawide-1080p" = {
      width = 2560;
      height = 1080;
    };
    "uwfhd" = {
      width = 2560;
      height = 1080;
    };
    "ultrawide-1440p" = {
      width = 3440;
      height = 1440;
    };
    "uwqhd" = {
      width = 3440;
      height = 1440;
    };
    "ultrawide-1600p" = {
      width = 3840;
      height = 1600;
    };
    "ultrawide-4k" = {
      width = 5120;
      height = 2160;
    };
    "ultrawide-5k" = {
      width = 5120;
      height = 2160;
    };
    "uw5k" = {
      width = 5120;
      height = 2160;
    };

    # Super Ultrawide 32:9 Resolutions
    "super-ultrawide" = {
      width = 5120;
      height = 1440;
    };
    "dqhd" = {
      width = 5120;
      height = 1440;
    };
    "super-ultrawide-4k" = {
      width = 7680;
      height = 2160;
    };
    "duhd" = {
      width = 7680;
      height = 2160;
    };
  };

  parseTransform =
    m:
    if m.transform != null then
      if m.transform.flipped then
        if m.transform.rotation == 90 then
          "flipped-90"
        else if m.transform.rotation == 180 then
          "flipped-180"
        else if m.transform.rotation == 270 then
          "flipped-270"
        else
          "flipped"
      else if m.transform.rotation == 90 then
        "90"
      else if m.transform.rotation == 180 then
        "180"
      else if m.transform.rotation == 270 then
        "270"
      else
        "normal"
    else
      let
        ori = lib.toLower (toString m.orientation);
      in
      if ori == "vertical" || ori == "portrait" || ori == "90" then
        "90"
      else if ori == "vertical-inverted" || ori == "portrait-inverted" || ori == "270" then
        "270"
      else if ori == "inverted" || ori == "180" then
        "180"
      else if ori == "flipped" || ori == "flipped-horizontal" then
        "flipped"
      else if ori == "flipped-vertical" || ori == "flipped-90" then
        "flipped-90"
      else
        "normal";

  parsePosition =
    m:
    let
      posX =
        if m.x != null then
          m.x
        else if m.position != null then
          m.position.x
        else
          null;
      posY =
        if m.y != null then
          m.y
        else if m.position != null then
          m.position.y
        else
          null;
    in
    if posX != null && posY != null then
      {
        x = posX;
        y = posY;
      }
    else if m.position != null then
      m.position
    else
      null;

  buildOutputConfig =
    m:
    let
      tform = parseTransform m;
      pos = parsePosition m;
      res =
        if m.width != null && m.height != null then
          "${toString m.width}x${toString m.height}"
        else if m.resolution != null && m.resolution != "auto" then
          let
            lower = lib.toLower (toString m.resolution);
            common = commonResolutions.${lower} or null;
          in
          if common != null then
            "${toString common.width}x${toString common.height}"
          else if lib.hasInfix "x" lower then
            lower
          else
            null
        else
          null;

      modeStr =
        if res != null then
          (if m.refresh != null then "${res}@${toString (m.refresh * 1.0)}" else res)
        else
          null;
    in
    lib.filterAttrs (_: v: v != null) (
      (lib.optionalAttrs (!m.enable) { off = { }; })
      // (lib.optionalAttrs (m.enable && modeStr != null) { mode = modeStr; })
      // (lib.optionalAttrs (m.enable && pos != null) {
        position._props = {
          inherit (pos) x y;
        };
      })
      // (lib.optionalAttrs (m.enable && m.scale != null) { scale = m.scale * 1.0; })
      // (lib.optionalAttrs (m.enable && tform != "normal") { transform = tform; })
      // (lib.optionalAttrs (m.enable && m.vrr == true) { variable-refresh-rate = { }; })
      // (lib.optionalAttrs (m.enable && m.vrr == "on-demand") {
        variable-refresh-rate._props = {
          on-demand = true;
        };
      })
      // (lib.optionalAttrs (m.enable && (m.focusAtStartup || m.primary)) { focus-at-startup = { }; })
      // (lib.optionalAttrs (m.enable && m.backdropColor != null) { backdrop-color = m.backdropColor; })
      // (lib.optionalAttrs (m.enable && m.backgroundColor != null) {
        background-color = m.backgroundColor;
      })
      // m.extraSettings
    );

  monitorSubmodule = _: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Output name/connector (e.g. DP-4, DP-5, eDP-1, HDMI-A-1) or EDID model string";
        example = "DP-4";
      };

      aliases = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional output names or EDID model strings that share this display configuration";
        example = [ "ASUSTek COMPUTER INC VG27WQ3B TALMTR031961" ];
      };

      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable or disable this display output";
      };

      resolution = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Display resolution preset (e.g. '1080p', '1440p', '4k', '720p', '1200p', '1600p', '5k',
          'ultrawide-1080p', 'ultrawide-1440p', 'super-ultrawide', 'steam-deck') or custom 'WIDTHxHEIGHT'
          string (e.g. '1920x1080', '2560x1440', '3840x2160'). Set to null or 'auto' for automatic mode.
        '';
        example = "1440p";
      };

      width = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Explicit monitor width in pixels. Overrides resolution preset if specified.";
        example = 2560;
      };

      height = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Explicit monitor height in pixels. Overrides resolution preset if specified.";
        example = 1440;
      };

      refresh = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.float lib.types.int);
        default = null;
        description = "Refresh rate in Hz (e.g. 60.0, 144.0, 165.0, 180.0, 240.0). If null, Niri chooses highest supported.";
        example = 180.0;
      };

      orientation = lib.mkOption {
        type = lib.types.enum [
          "horizontal"
          "vertical"
          "vertical-inverted"
          "inverted"
          "landscape"
          "portrait"
          "portrait-inverted"
          "flipped"
          "flipped-horizontal"
          "flipped-vertical"
          "0"
          "90"
          "180"
          "270"
        ];
        default = "horizontal";
        description = ''
          Monitor orientation / rotation:
          - 'horizontal' / 'landscape' / '0': Normal horizontal orientation (0 deg)
          - 'vertical' / 'portrait' / '90': Vertical / portrait orientation rotated 90 deg clockwise
          - 'vertical-inverted' / 'portrait-inverted' / '270': Vertical / portrait orientation rotated 270 deg clockwise
          - 'inverted' / '180': 180 deg upside-down orientation
          - 'flipped' / 'flipped-horizontal': Horizontally flipped
          - 'flipped-vertical': Vertically flipped 90 deg
        '';
        example = "vertical";
      };

      transform = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              rotation = lib.mkOption {
                type = lib.types.enum [
                  0
                  90
                  180
                  270
                ];
                default = 0;
                description = "Rotation angle in degrees (0, 90, 180, 270)";
              };
              flipped = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether to flip vertically";
              };
            };
          }
        );
        default = null;
        description = "Detailed transform configuration. Overrides orientation if specified.";
      };

      scale = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.float lib.types.int);
        default = null;
        description = "Display scaling factor (e.g. 1.0, 1.25, 1.5, 2.0).";
        example = 1.0;
      };

      position = lib.mkOption {
        type = lib.types.nullOr (
          lib.types.submodule {
            options = {
              x = lib.mkOption {
                type = lib.types.int;
                default = 0;
                description = "X position in logical pixels";
              };
              y = lib.mkOption {
                type = lib.types.int;
                default = 0;
                description = "Y position in logical pixels";
              };
            };
          }
        );
        default = null;
        description = "Monitor position in global coordinate space { x = 0; y = 0; }";
        example = {
          x = 0;
          y = 0;
        };
      };

      x = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Convenience X position in logical pixels (overrides position.x)";
        example = 0;
      };

      y = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Convenience Y position in logical pixels (overrides position.y)";
        example = 0;
      };

      vrr = lib.mkOption {
        type = lib.types.either lib.types.bool (lib.types.enum [ "on-demand" ]);
        default = false;
        description = "Variable Refresh Rate (VRR / FreeSync / G-Sync / Adaptive Sync). Can be true, false, or 'on-demand'.";
        example = true;
      };

      focusAtStartup = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this output should be focused when Niri starts.";
      };

      primary = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this output should be designated as the primary display (focus at startup, Xwayland primary monitor).";
      };

      backdropColor = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Backdrop color drawn behind workspaces or in overview.";
      };

      backgroundColor = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Background solid color for this monitor.";
      };

      extraSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Extra raw Niri output settings passed directly to output config.";
      };
    };
  };

  outputChildren = lib.concatMap (
    m:
    let
      outCfg = buildOutputConfig m;
      allNames = [ m.name ] ++ m.aliases;
    in
    map (name: {
      output = {
        _args = [ name ];
      }
      // outCfg;
    }) allNames
  ) cfg.monitors;

  primaryMonitors = lib.filter (m: m.enable && (m.primary || m.focusAtStartup)) cfg.monitors;
  primaryMonitor = if primaryMonitors != [ ] then lib.head primaryMonitors else null;

  xrandrPrimaryScript =
    if cfg.setXwaylandPrimary && primaryMonitor != null then
      let
        allPrimaryNames = [ primaryMonitor.name ] ++ primaryMonitor.aliases;
        namesListStr = lib.concatMapStringsSep " " (n: "\"${n}\"") allPrimaryNames;
      in
      pkgs.writeShellScriptBin "niri-set-primary-output" ''
        for _ in $(seq 1 30); do
          if [ -n "$DISPLAY" ] && ${pkgs.xrandr}/bin/xrandr --display "$DISPLAY" >/dev/null 2>&1; then
            for name in ${namesListStr}; do
              if ${pkgs.xrandr}/bin/xrandr --display "$DISPLAY" 2>/dev/null | grep -q "^$name connected"; then
                ${pkgs.xrandr}/bin/xrandr --display "$DISPLAY" --output "$name" --primary
                exit 0
              fi
            done
          fi
          sleep 0.2
        done
      ''
    else
      null;
in
{
  options.myFeatures.platforms.desktops.niri = {
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule monitorSubmodule);
      default = [ ];
      description = ''
        List of monitors configured for Niri.
        Supports presets (e.g. '1080p', '1440p', '4k', 'ultrawide-1440p'), orientations ('horizontal', 'vertical'),
        VRR, refresh rates, positions, and scaling.
      '';
      example = [
        {
          name = "DP-4";
          resolution = "1440p";
          refresh = 180.0;
          orientation = "horizontal";
          position = {
            x = 0;
            y = 0;
          };
          vrr = true;
          primary = true;
        }
        {
          name = "DP-5";
          resolution = "1080p";
          refresh = 165.0;
          orientation = "vertical";
          position = {
            x = 2560;
            y = 0;
          };
          vrr = true;
        }
      ];
    };

    setXwaylandPrimary = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to automatically set the designated primary monitor in Xwayland at startup.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.xrandr
    ]
    ++ lib.optional (xrandrPrimaryScript != null) xrandrPrimaryScript;

    myFeatures.platforms.desktops.niri.settings = {
      _children =
        (lib.optionals (cfg.monitors != [ ]) outputChildren)
        ++ (lib.optionals (xrandrPrimaryScript != null) [
          {
            spawn-at-startup._args = [
              "${xrandrPrimaryScript}/bin/niri-set-primary-output"
            ];
          }
        ]);
    };
  };
}

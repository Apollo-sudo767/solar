{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myFeatures.programs.fastfetch;

  # Mirror the pattern used in gruvboxNiriRice.nix — read from the dedicated
  # usernames list rather than config.users.users, which causes infinite recursion.
  userList = lib.filter
    (n: n != "enable" && n != "usernames")
    config.myFeatures.core.users.usernames;
in {

  # ── OPTIONS ───────────────────────────────────────────────────────────────
  options.myFeatures.programs.fastfetch = {
    enable = lib.mkEnableOption "fastfetch system info fetcher";

    theme = lib.mkOption {
      type    = lib.types.enum [ "gruvbox" "catppuccin" "nord" "tokyonight" ];
      default = "gruvbox";
      description = "Colour theme to use for fastfetch output.";
    };

    showBattery = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = "Show battery module. Disable on desktops.";
    };

    showPublicIp = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = "Show public IP (makes an outbound HTTP request on every shell open).";
    };

    logoType = lib.mkOption {
      type    = lib.types.enum [ "auto" "kitty" "sixel" "chafa" "ascii" ];
      default = "auto";
      description = "Logo rendering backend.";
    };
  };

  # ── CONFIG ────────────────────────────────────────────────────────────────
  config = lib.mkIf cfg.enable {

    # Apply to all users in myFeatures.core.users.usernames, exactly like
    # gruvboxNiriRice.nix does — avoids the infinite recursion from reading
    # config.users.users during evaluation.
    home-manager.users = lib.genAttrs userList (_name:

      let
        # ── Theme palettes ───────────────────────────────────────────────
        palette = {
          gruvbox = {
            keys  = "yellow"; title = "208";     output = "white";
            sep   = "90"; # Changed from darkgray to 90
            sys   = "yellow"; de    = "208";     hw     = "red";
            net   = "cyan";   bat   = "blue";    time   = "208";
          };
          catppuccin = {
            keys  = "blue";   title = "magenta"; output = "white";
            sep   = "90"; # Changed from darkgray to 90
            sys   = "blue";   de    = "141";     hw     = "yellow";
            net   = "cyan";   bat   = "green";   time   = "141";
          };
          nord = {
            keys  = "cyan";   title = "blue";    output = "white";
            sep   = "darkgray";
            sys   = "cyan";   de    = "blue";    hw     = "red";
            net   = "green";  bat   = "cyan";    time   = "blue";
          };
          tokyonight = {
            keys  = "blue";   title = "magenta"; output = "white";
            sep   = "darkgray";
            sys   = "blue";   de    = "magenta"; hw     = "red";
            net   = "cyan";   bat   = "green";   time   = "magenta";
          };
        };

        p = palette.${cfg.theme};

        batteryModule  = lib.optional cfg.showBattery
          { type = "battery";  key = " Battery";  keyColor = p.bat; };

        publicIpModule = lib.optional cfg.showPublicIp
          { type = "publicIp"; key = "󰖟 Public IP"; keyColor = p.net; };

      in {
        programs.fastfetch = {
          enable = true;

          settings = {
            # ── Logo ──────────────────────────────────────────────────
            logo = {
              source  = "auto";
              type    = cfg.logoType;
              width   = 24;
              height  = 12;
              padding = { top = 2; left = 2; right = 2; };
            };

            # ── Display ───────────────────────────────────────────────
            display = {
              separator = "  ";
              color     = { keys = p.keys; title = p.title; output = p.output; };
              bar       = { char.elapsed = "█"; charTotal = "░"; width = 10; };
            };

            # ── Modules ───────────────────────────────────────────────
            modules =
              [
                # Header
                { type = "title"; format = "{user-name}@{host-name}";
                  color = { user = p.title; at = p.sep; host = p.keys; }; }
                { type = "separator"; string = "─"; length = 40; color = p.sep; }
                { type = "colors"; symbol = "circle"; paddingLeft = 1; }
                { type = "separator"; string = "─"; length = 40; color = p.sep; }

                # System
                { type = "os";           key = " OS";       keyColor = p.sys; }
                { type = "kernel";       key = " Kernel";   keyColor = p.sys; }
                { type = "shell";        key = " Shell";    keyColor = p.sys; }
                { type = "terminal";     key = " Terminal"; keyColor = p.sys; }
                { type = "terminalFont"; key = " Font";     keyColor = p.sys; }

                # DE / WM
                { type = "wm";      key = "󱂬 WM";      keyColor = p.de; }
                { type = "de";      key = " DE";       keyColor = p.de; }
                { type = "wmTheme"; key = " WM Theme"; keyColor = p.de; }
                { type = "icons";   key = " Icons";    keyColor = p.de; }
                { type = "cursor";  key = " Cursor";   keyColor = p.de; }

                # Packages
                { type = "packages"; key = "󰏗 Packages"; keyColor = "green"; }

                # Hardware
                { type = "host";   key = "󰌢 Host"; keyColor = p.hw; }
                { type = "cpu";    key = " CPU";  keyColor = p.hw;
                  showPeCoreCount = true; temp = true; tempUnit = "c"; }
                { type = "gpu";    key = "󰍛 GPU";  keyColor = p.hw;
                  temp = true; tempUnit = "c"; }
                { type = "memory"; key = " RAM";  keyColor = p.hw; }
                { type = "swap";   key = " Swap"; keyColor = p.hw; }
                { type = "disk";   key = "󰋊 Disk"; keyColor = p.hw; }

                # Network
                { type = "hostname"; key = "󰒋 Hostname"; keyColor = p.net; }
                { type = "localIp";  key = "󰩠 Local IP"; keyColor = p.net;
                  showIpv4 = true; showIpv6 = false; }
              ]

              ++ publicIpModule

              ++ [
                { type = "uptime";    key = "󰅐 Uptime";   keyColor = p.bat; }
              ]
              ++ batteryModule
              ++ [
                { type = "loadavg";   key = " Load avg";  keyColor = p.bat; }
                { type = "processes"; key = " Processes"; keyColor = p.bat; }

                { type = "dateTime"; key = "󰃶 Date & Time"; keyColor = p.time;
                  format = "%A, %d %b %Y  %H:%M"; }

                { type = "separator"; string = "─"; length = 40; color = p.sep; }
              ];
          };
        };
      }
    );
  };
}

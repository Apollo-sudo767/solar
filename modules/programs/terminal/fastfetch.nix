{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
  ...
}:

let
  cfg = config.myFeatures.programs.terminal.fastfetch;
  # Filter to ensure we only target actual usernames
  userList = lib.filter (n: n != "enable" && n != "usernames") config.myFeatures.core.system.users.usernames;
in
{
  options.myFeatures.programs.terminal.fastfetch = {
    enable = lib.mkEnableOption "fastfetch system info fetcher";
    theme = lib.mkOption {
      type = lib.types.enum [
        "gruvbox"
        "catppuccin"
        "nord"
        "tokyonight"
      ];
      default = "gruvbox";
      description = "Colour theme to use for fastfetch output.";
    };
    showBattery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show battery module.";
    };
    showPublicIp = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show public IP.";
    };
    logoType = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "kitty"
        "sixel"
        "chafa"
        "ascii"
      ];
      default = "auto";
      description = "Logo rendering backend.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users = lib.genAttrs userList (
      _name:
      let
        palette = {
          gruvbox = {
            keys = "yellow";
            title = "208";
            output = "white";
            sep = "90";
            sys = "yellow";
            de = "208";
            hw = "red";
            net = "cyan";
            bat = "blue";
            time = "208";
          };
          # Add other palettes here as needed
        };

        p = palette.${cfg.theme};

        # Helper to create a bracketed group
        startGroup = name: color: {
          type = "custom";
          format = "╭─ ${name}";
          outputColor = color;
        };
        endGroup = color: {
          type = "custom";
          format = "╰───────────────────────────────";
          outputColor = color;
        };

      in
      {
        programs.fastfetch = {
          enable = true;
          settings = {
            logo = {
              # Protocol: Force NixOS logo to prevent Arch leakage
              source = "nixos";
              type = cfg.logoType;
              width = 24;
              height = 12;
              padding = {
                top = 2;
                left = 2;
                right = 2;
              };
            };

            display = {
              separator = "  ";
              color = {
                keys = p.keys;
                title = p.title;
                output = p.output;
              };
            };

            modules = [
              {
                type = "title";
                format = "{user-name}@{host-name}";
                color = {
                  user = p.title;
                  at = p.sep;
                  host = p.keys;
                };
              }
              {
                type = "colors";
                symbol = "circle";
                paddingLeft = 2;
              }
              { type = "break"; }

              # ── SYSTEM GROUP ──
              (startGroup "System" p.sys)
              {
                type = "os";
                key = "│ 󰣇 OS      ";
                keyColor = p.sys;
              }
              {
                type = "kernel";
                key = "│ 󰒋 Kernel  ";
                keyColor = p.sys;
              }
              {
                type = "shell";
                key = "│ 󱆃 Shell   ";
                keyColor = p.sys;
              }
              {
                type = "terminal";
                key = "│ 󰆍 Terminal";
                keyColor = p.sys;
              }
              (endGroup p.sys)
              { type = "break"; }

              # ── DESKTOP GROUP ──
              (startGroup "Desktop" p.de)
              {
                type = "wm";
                key = "│ 󱂬 WM      ";
                keyColor = p.de;
              }
              {
                type = "wmTheme";
                key = "│ 󰉼 Theme   ";
                keyColor = p.de;
              }
              {
                type = "icons";
                key = "│ 󰀻 Icons   ";
                keyColor = p.de;
              }
              {
                type = "packages";
                key = "│ 󰏗 Packages";
                keyColor = p.de;
              }
              (endGroup p.de)
              { type = "break"; }

              # ── HARDWARE GROUP ──
              (startGroup "Hardware" p.hw)
              {
                type = "host";
                key = "│ 󰌢 Host    ";
                keyColor = p.hw;
              }
              {
                type = "cpu";
                key = "│ 󰻠 CPU     ";
                keyColor = p.hw;
              }
              {
                type = "gpu";
                key = "│ 󰍛 GPU     ";
                keyColor = p.hw;
              }
              {
                type = "memory";
                key = "│ 󰍛 RAM     ";
                keyColor = p.hw;
              }
              {
                type = "disk";
                key = "│ 󰋊 Disk    ";
                keyColor = p.hw;
              }
              (endGroup p.hw)
              { type = "break"; }

              # ── NETWORK GROUP ──
              (startGroup "Network" p.net)
              {
                type = "localIp";
                key = "│ 󰩠 Local   ";
                keyColor = p.net;
                showIpv4 = true;
              }
              (endGroup p.net)
              { type = "break"; }

              # ── TIME GROUP (Corrected Syntax & Themed) ──
              (startGroup "Time" p.time)
              {
                type = "datetime";
                key = "│ 󰃶 Date    ";
                keyColor = p.time;
                # Nixpkgs-Unstable fastfetch uses direct strftime-style formatting
                format = "%A, %B %d %Y";
              }
              (endGroup p.time)

              (lib.optional (cfg.showBattery) {
                type = "battery";
                key = "󰁹 Battery";
                keyColor = p.bat;
              })
            ];
          };
        };
      }
    );
  };
}

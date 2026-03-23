{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.fastfetch;
  # Filter to get just the usernames as strings
  usernames = lib.filter (n: n != "enable" && n != "usernames") config.myFeatures.core.users.usernames;
in
{
  options.myFeatures.programs.fastfetch.enable = lib.mkEnableOption "Apollo's Riced Fastfetch";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.fastfetch ];

    home-manager.users = lib.genAttrs usernames (name: {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            source = "nixos_small";
            padding = { right = 4; };
          };
          display = {
            separator = " ❯ ";
            color = "magenta";
            binaryPrefix = "jedec";
          };
          modules = [
            "title"
            "separator"
            { type = "os"; key = "󱄅 OS  "; }
            { type = "kernel"; key = " KRN "; }
            { type = "uptime"; key = "󰅐 UPT "; }
            { type = "packages"; key = "󰏖 PKG "; }
            "break"
            {
              type = "cpu";
              key = "󰻠 CPU ";
              showPeCoreCount = true;
              temp = true;
            }
            {
              type = "gpu";
              key = "󰢮 GPU ";
              format = "{2}";
              temp = true;
            }
            { type = "memory"; key = "󰍛 MEM "; }
            { type = "disk"; key = "󰋊 DSK "; folders = "/"; }
            {
              type = "monitor";
              key = "󰍹 RES ";
              compactType = "unquoted";
            }
            "break"
            { type = "localip"; key = "󰩟 LAN "; showIpv4 = true; }
            { type = "battery"; key = "󰁹 BAT "; }
            "break"
            "colors"
          ];
        };
      };

      # Move the Zsh init here so it uses the Home Manager module
      programs.zsh.initExtra = lib.mkAfter ''
        fastfetch
      '';
    });
  };
}

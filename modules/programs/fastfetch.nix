{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.fastfetch;
in
{
  options.myFeatures.programs.fastfetch.enable = lib.mkEnableOption "Apollo's Riced Fastfetch";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.fastfetch ];

    # FIX: Only map over the list of strings in .usernames
    home-manager.users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
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
              type = "display";
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
    });

    programs.zsh.interactiveShellInit = ''
      fastfetch
    '';
  };
}

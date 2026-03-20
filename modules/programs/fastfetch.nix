{ config, lib, pkgs, ... }:

let
  cfg = config.myFeatures.programs.fastfetch;
in
{
  options.myFeatures.programs.fastfetch.enable = lib.mkEnableOption "Apollo's Riced Fastfetch";

  config = lib.mkIf cfg.enable {
    # Install the package system-wide so 'fastfetch' command is always available
    environment.systemPackages = [ pkgs.fastfetch ];

    home-manager.users = lib.mapAttrs (name: _: {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            source = "nixos_small";
            padding = { right = 4; };
          };
          display = {
            separator = " ❯ ";
            color = "magenta"; # Stylix will override this to Gruvbox magenta/purple
            binaryPrefix = "jedec";
          };
          modules = [
            # --- USER & HOST ---
            "title" # This shows 'apollo@nyx' or 'nova@nova-pc'
            "separator"
            
            # --- SYSTEM INFO ---
            { type = "os"; key = "󱄅 OS  "; }
            { type = "kernel"; key = " KRN "; }
            { type = "uptime"; key = "󰅐 UPT "; }
            { type = "packages"; key = "󰏖 PKG "; }
            "break"
            
            # --- HARDWARE SPECS (Phanes Parity) ---
            { 
              type = "cpu"; 
              key = "󰻠 CPU "; 
              showPeCoreCount = true; 
              temp = true; # Requires lm_sensors enabled in core
            }
            { 
              type = "gpu"; 
              key = "󰢮 GPU "; 
              format = "{2}"; # Shows "NVIDIA GeForce RTX 4070 Ti"
              temp = true;
            }
            { type = "memory"; key = "󰍛 MEM "; }
            { type = "disk"; key = "󰋊 DSK "; folders = "/"; }
            { 
              type = "display"; 
              key = "󰍹 RES "; 
              compactType = "unquoted"; # Shows "2560x1440 @ 180Hz"
            }
            "break"

            # --- NETWORK & MISC ---
            { type = "localip"; key = "󰩟 LAN "; showIpv4 = true; }
            { type = "battery"; key = "󰁹 BAT "; } # Only displays if a battery is detected (Laptop)
            
            "break"
            "colors" # The Gruvbox color palette blocks
          ];
        };
      };
    }) config.myFeatures.users;

    # Optional: Auto-run on shell start (Migrated logic)
    programs.zsh.interactiveShellInit = ''
      fastfetch
    '';
  };
}

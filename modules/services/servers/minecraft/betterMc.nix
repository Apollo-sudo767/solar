{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.myFeatures.services.servers.minecraft.better-mc;

  # Better MC 1.20.1 (Forge) - Example URL/Hash
  # Note: You should find the direct server-pack download URL from CurseForge/Modrinth
  modpack = pkgs.fetchzip {
    url = "https://cdn.modrinth.com/data/shFhR8Vx/versions/Ur9uoHH5/Better%20MC%20%5BFABRIC%5D%20-%20BMC2%20v26.5.mrpack";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual hash
  };
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  options.myFeatures.services.servers.minecraft.better-mc = {
    enable = lib.mkEnableOption "Better MC 1.20.1 (Forge)";
    port = lib.mkOption {
      type = lib.types.port;
      default = 25565;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;

      servers.better-mc = {
        enable = true;
        # Better MC 1.20.1 typically uses Forge
        package = pkgs.forgeServers.forge-1_20_1;

        # Standard Performance Flags for heavy modpacks
        jvmOpts = "-Xmx8G -Xms8G -XX:+UseG1GC -Djava.net.preferIPv4Stack=true";

        # Symlink the entire modpack content
        symlinks = {
          "mods" = "${modpack}/mods";
          "config" = "${modpack}/config";
          "defaultconfigs" = "${modpack}/defaultconfigs";
          "scripts" = "${modpack}/scripts";
        };

        serverProperties = {
          server-port = cfg.port;
          online-mode = true;
          motd = "Solar | Better MC 1.20.1";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];
  };
}

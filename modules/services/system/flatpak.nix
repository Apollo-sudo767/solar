{
  config,
  lib,
  ...
}:

let
  cfg = config.myFeatures.services.system.flatpak;
in
{
  options.myFeatures.services.system.flatpak = {
    enable = lib.mkEnableOption "Flatpak Support";

    packages = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
      description = "Declarative Flatpak packages to install via nix-flatpak.";
      example = [
        "io.mrarm.mcpelauncher"
        "org.vinegarhq.Sober"
      ];
    };

    remotes = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
      description = "Additional Flatpak remotes to configure via nix-flatpak.";
    };

    update = {
      onActivation = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to upgrade Flatpak applications during system activation.";
      };
      auto = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable periodic automatic Flatpak updates via systemd timer.";
        };
        onCalendar = lib.mkOption {
          type = lib.types.str;
          default = "weekly";
          description = "Frequency of periodic Flatpak updates.";
        };
      };
    };

    overrides = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Flatpak overrides to configure via nix-flatpak.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      inherit (cfg) packages;
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ]
      ++ cfg.remotes;
      update = {
        onActivation = cfg.update.onActivation;
        auto = {
          enable = cfg.update.auto.enable;
          onCalendar = cfg.update.auto.onCalendar;
        };
      };
      overrides = lib.mkIf (cfg.overrides != { }) cfg.overrides;
    };

    xdg.portal.enable = true; # Required for Flatpak integration [cite: 32]

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf config.myFeatures.core.system.preservation.enable
        {
          directories = [
            "/var/lib/flatpak"
          ];
          users = lib.genAttrs config.myFeatures.core.system.users.usernames (_name: {
            directories = [
              ".local/share/flatpak"
              ".var"
            ];
          });
        };
  };
}

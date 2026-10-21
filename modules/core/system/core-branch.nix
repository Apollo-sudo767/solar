# modules/core/system/core-branch.nix
# ============================================================================
# Core System Foundation (`core-branch`)
# ============================================================================
# Acts as the primary baseline switch for every Solar host. Enabling
# `myFeatures.core.system.core-branch.enable = true;` automatically turns on
# essential system defaults (Nix store settings, Cachix binary caches, fonts,
# timezone/locale, OpenSSH, user accounts, bootloader, and Disko on Linux)
# using `lib.mkDefault` so any host can override individual pieces.
{
  lib,
  config,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.system.core-branch;
in
{
  options.myFeatures.core.system.core-branch = {
    enable = lib.mkEnableOption "Core System Foundation";
    usePersistence = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Wipe-on-Boot Preservation (ephemeral tmpfs `/` with persistent `/persist`) for this host.";
    };
    virtualization = {
      docker = lib.mkEnableOption "Docker Engine";
      libvirt = lib.mkEnableOption "Virt-Manager/VMs";
    };
  };

  config = lib.mkIf (cfg.enable && isTotal) (
    lib.mkMerge [
      # 1. Universal Core Features (Evaluated on both macOS and Linux)
      {
        myFeatures.core = {
          nix.nix-settings.enable = lib.mkDefault true;
          nix.cachix.enable = lib.mkDefault true;
          system.fonts.enable = lib.mkDefault true;
          system.localeChicago.enable = lib.mkDefault true;
          security.ssh.enable = lib.mkDefault true;
          system.users.enable = lib.mkDefault true;
          system.preservation.enable = lib.mkIf (cfg.usePersistence && !isDarwin) true;
          system.disko.enable = lib.mkDefault (!isDarwin);
        };
      }

      # 2. Linux-Only Core Features (Completely omitted on macOS)
      (lib.optionalAttrs (!isDarwin) {
        myFeatures.core = {
          boot.enable = lib.mkDefault true;
          system.virtualization = {
            enable = lib.mkIf (cfg.virtualization.docker || cfg.virtualization.libvirt) (lib.mkDefault true);
            docker = lib.mkIf cfg.virtualization.docker (lib.mkDefault true);
            libvirt = lib.mkIf cfg.virtualization.libvirt (lib.mkDefault true);
          };
        };
      })
    ]
  );
}

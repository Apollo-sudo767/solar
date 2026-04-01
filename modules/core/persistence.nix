{ config, lib, inputs, ... }:

{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options.myFeatures.core.persistence.enable = lib.mkEnableOption "Impermanence and persistent storage";

  config = lib.mkIf config.myFeatures.core.persistence.enable {
    # 1. Necessary for Home Manager to mount persistent files in the user directory
    programs.fuse.userAllowOther = true;

    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"           # Stores your host keys for SOPS/Age decryption
        "/var/lib/sbctl"     # Secure Boot keys
        "/etc/secureboot"
      ];
      files = [
        "/etc/machine-id"
        "/etc/adjtime"
        "/etc/passwd"        # Essential for persistent user definitions
        "/etc/shadow"        # Essential for persistent password hashes
        "/etc/group"
      ];

      # 2. System-level user persistence
      # This handles large data that doesn't need complex symlinking
      users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
        directories = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "src"
          ".mozilla"
          ".local/share/PrismLauncher"
          ".local/share/direnv"
          ".ssh"
          ".config/sops"     # Ensures user-level SOPS keys persist
        ];
        files = [
          ".bash_history"
          ".zsh_history"
        ];
      });
    };

    # 3. Ensure critical directories exist on the persistent drive before boot
    systemd.tmpfiles.rules = [
      "d /nix/persist/etc/ssh 0755 root root -"
      "d /nix/persist/var/lib/bluetooth 0700 root root -"
      "d /nix/persist/var/lib/nixos 0755 root root -"
    ];
  };
}

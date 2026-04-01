{ config, lib, inputs, ... }:

{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options.myFeatures.core.persistence.enable = lib.mkEnableOption "Impermanence and persistent storage";

  config = lib.mkIf config.myFeatures.core.persistence.enable {
    # This creates the link between the persistent disk and the ephemeral RAM root
    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"
        "/var/lib/sbctl"
        "/etc/secureboot"
      ];
      files = [
        "/etc/machine-id"
        "/etc/adjtime"
        "/etc/group"
        "/etc/shadow"
        "/etc/passwd"
      ];
      # Dynamically applies persistence to your users (defaulting to "apollo")
      users = lib.genAttrs config.myFeatures.core.users.usernames (name: {
        directories = [
          "Downloads"
          "Music"
          "Pictures"
          "Documents"
          "Videos"
          "src"
          ".mozilla" # Firefox persistence
          ".local/share/PrismLauncher" # Prism persistence
          ".local/share/direnv"
          ".ssh"
          ".config/sops"
        ];
      });
    };
  };
}

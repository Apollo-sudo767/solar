# modules/core/security/ssh.nix
# ============================================================================
# OpenSSH Daemon, Client Agent & Host Key Persistence
# ============================================================================
# Enables OpenSSH across Linux and macOS, pre-populates GitHub's Ed25519 host
# key, preserves `SSH_AUTH_SOCK` across `sudo` invocations on Linux, disables
# the conflicting GNOME `gcr-ssh-agent` so hardware keys work reliably, and
# persists `/etc/ssh` host keys across reboots on ephemeral-root systems.
{
  config,
  lib,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.security.ssh;
in
{
  options.myFeatures.core.security.ssh = {
    enable = lib.mkEnableOption "SSH Service";
  };

  config = lib.mkIf (cfg.enable && isTotal) (
    lib.mkMerge [
      # 1. Cross-Platform SSH Configuration (macOS & Linux)
      {
        services.openssh.enable = true;

        programs.ssh.extraConfig = ''
          AddKeysToAgent yes
        '';

        programs.ssh.knownHosts."github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      }

      # 2. Linux-Only OpenSSH Daemon, Sudo Socket Forwarding & Key Persistence
      (lib.optionalAttrs (!isDarwin) {
        # Preserve SSH agent socket when elevating privileges with `sudo`
        security.sudo.extraConfig = ''
          Defaults env_keep += "SSH_AUTH_SOCK"
        '';

        programs.ssh.startAgent = true;

        services.openssh = {
          hostKeys = [
            {
              path =
                if config.myFeatures.core.system.core-branch.usePersistence then
                  "${config.myFeatures.core.system.preservation.persistentPath}/etc/ssh/ssh_host_ed25519_key"
                else
                  "/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ];
          settings = {
            PermitRootLogin = lib.mkDefault "prohibit-password";
            PasswordAuthentication = lib.mkDefault true;
          };
        };

        # Disable conflicting GCR agent so the standard OpenSSH agent handles hardware keys
        services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              directories = [
                {
                  directory = "/etc/ssh";
                  mode = "0755";
                }
              ];
            };
      })
    ]
  );
}

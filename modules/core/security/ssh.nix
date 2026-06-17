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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. Common configuration for both Mac and Linux
      {
        services.openssh.enable = true;
        programs.ssh.startAgent = true;
        # Disable conflicting GCR agent to ensure OpenSSH agent works for hardware keys
        services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

        programs.ssh.extraConfig = ''
          AddKeysToAgent yes
        '';

        programs.ssh.knownHosts."github.com".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      }

      # 2. Agenix-specific sudo preservation (Linux-only)
      (lib.optionalAttrs (!isDarwin) (lib.mkIf (config.myFeatures.core.security.agenix.enable or false) {
        security.sudo.extraConfig = ''
          Defaults env_keep += "SSH_AUTH_SOCK"
        '';
      }))

      # 3. Linux-only configuration (Shielded from the Mac Evaluator)
      (lib.optionalAttrs (!isDarwin) {
        services.openssh.settings = {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = true;
        };

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

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
      }

      # 2. Linux-only configuration (Shielded from the Mac Evaluator)
      (lib.optionalAttrs (!isDarwin) {
        services.openssh.settings = {
          PermitRootLogin = "prohibit-password";
          PasswordAuthentication = true;
        };

        preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
          lib.mkIf config.myFeatures.core.system.preservation.enable
            {
              files = [
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
                "/etc/ssh/ssh_host_rsa_key"
                "/etc/ssh/ssh_host_rsa_key.pub"
              ];
            };
      })
    ]
  );
}

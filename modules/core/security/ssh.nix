{
  config,
  lib,
  pkgs,
  isTotal,
  isDarwin,
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
          PermitRootLogin = "no";
          PasswordAuthentication = true;
        };
      })
    ]
  );
}

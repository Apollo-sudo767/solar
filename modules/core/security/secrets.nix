{
  config,
  lib,
  inputs,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.security.agenix;
  secretsDir = inputs.solar-secrets + "/secrets";
in
{
  config = lib.mkMerge [
    # 1. Core Secrets (User passwords, enabled via agenixPassword toggle)
    (lib.mkIf
      (
        config.myFeatures.core.system.users.agenixPassword
        && cfg.usePrivateSecrets
        && (builtins.hasAttr "solar-secrets" inputs)
      )
      {
        age.secrets."password-apollo.age".rekeyFile = "${secretsDir}/apollo-passwd.age";
        # Allow host-specific password secrets for testing/overrides
        age.secrets."password-${config.networking.hostName}.age".rekeyFile =
          "${secretsDir}/apollo-passwd.age";
      }
    )

    # 2. Optional Secrets (Only if agenix feature is enabled)
    (lib.mkIf (cfg.enable && cfg.usePrivateSecrets && (builtins.hasAttr "solar-secrets" inputs)) {
      age.secrets."wifi.age".rekeyFile = "${secretsDir}/maximus-wifi.age";
    })
  ];
}

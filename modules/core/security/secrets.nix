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
  config = lib.mkIf (cfg.enable && cfg.usePrivateSecrets && (builtins.hasAttr "solar-secrets" inputs)) {
    age.secrets = {
      "wifi.age".rekeyFile = "${secretsDir}/maximus-wifi.age";
      "password-apollo.age".rekeyFile = "${secretsDir}/apollo-passwd.age";
    };
  };
}

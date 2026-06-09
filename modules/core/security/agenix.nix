{
  config,
  lib,
  pkgs,
  inputs,
  isDarwin,
  isTotal,
  ...
}:

let
  cfg = config.myFeatures.core.security.agenix;
in
{
  options.myFeatures.core.security.agenix = {
    enable = lib.mkEnableOption "agenix-rekey for secret management";

    usePrivateSecrets = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to look for secrets inside the private solar-secrets repository input.";
    };
  };

  config = lib.mkIf cfg.enable {
    age.rekey = {
      storageMode = "local";
      localStorageDir = inputs.self + "/rekeyed/${config.networking.hostName}";
      
      masterIdentities = [
        # YubiKey identity path (this is a constant string used by the plugin)
        "yubikey" 
        "/home/apollo/src/solar-secrets/master/today.txt"
        "/Users/apollo/src/solar-secrets/master/today.txt"
        "/home/apollo/.ssh/id_ed25519"
        "/Users/apollo/.ssh/id_ed25519"
      ];

      agePlugins = [
        pkgs.age-plugin-yubikey
      ] ++ lib.optional isDarwin pkgs.age-plugin-se;

      extraEncryptionPubkeys =
        if cfg.usePrivateSecrets && (builtins.hasAttr "solar-secrets" inputs) then
          let
            masterDir = inputs.solar-secrets + "/master";
          in
          if builtins.pathExists masterDir then
            builtins.concatLists (
              lib.mapAttrsToList (
                name: type:
                if type == "regular" && lib.hasSuffix ".pub" name then
                  [ (lib.strings.trim (builtins.readFile (masterDir + "/${name}"))) ]
                else
                  [ ]
              ) (builtins.readDir masterDir)
            )
          else
            [ ]
        else
          [ ];

      hostPubkey =
        let
          path =
            if cfg.usePrivateSecrets && (builtins.hasAttr "solar-secrets" inputs) then
              "${inputs.solar-secrets}/hosts/${config.networking.hostName}.pub"
            else
              inputs.self + "/secrets/hosts/${config.networking.hostName}.pub";
        in
        if builtins.pathExists path then
          lib.strings.trim (builtins.readFile path)
        else
          "age1vdk2uqhss7xuacntfx95rkcplluwzx33mcxr66rdhu0sh5a0e5rsffrf34";
    };

    age.identityPaths = [
      "/persist/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    preservation.preserveAt."${config.myFeatures.core.system.preservation.persistentPath}" =
      lib.mkIf (!isDarwin && config.myFeatures.core.system.preservation.enable) {
        directories = [ { directory = "/etc/ssh"; mode = "0755"; } ];
        files = [ "/etc/ssh/ssh_host_ed25519_key" "/etc/ssh/ssh_host_ed25519_key.pub" ];
      };

    # Enable pcscd for YubiKey support on Linux
    services.pcscd.enable = lib.mkIf (!isDarwin) true;
  };
}

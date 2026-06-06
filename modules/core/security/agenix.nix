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
    masterIdentities = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "List of public keys for rekeying (master identities).";
    };
  };

  config = lib.mkMerge [
    {
      age.rekey.masterIdentities =
        let
          yubikey = ../../../secrets/master/yubikey.pub;
          se = ../../../secrets/master/se.pub;
          dev = ../../../secrets/master/dev.txt;
        in
        (lib.optional (builtins.pathExists yubikey) yubikey)
        ++ (lib.optional (builtins.pathExists se) se)
        ++ (lib.optional (builtins.pathExists dev) dev)
        # Fallback to a dummy if nothing exists yet
        ++ (lib.optional
          (!(builtins.pathExists yubikey) && !(builtins.pathExists se) && !(builtins.pathExists dev))
          (
            builtins.toFile "dummy.txt" "AGE-SECRET-KEY-1UYYT20446YSN3W8DR7GU46AD8H3JDDEL4N0PKAQ24JUQPSF3NTWSY32NRG"
          )
        );
    }
    (lib.mkIf cfg.enable {
      age.rekey = {
        storageMode = "local";
        localStorageDir = ../../../secrets/rekeyed/${config.networking.hostName};

        agePlugins = [
          pkgs.age-plugin-yubikey
        ]
        ++ lib.optional isDarwin pkgs.age-plugin-se;

        # hostPubkey must be the actual age1... recipient address or a path to a clean public key file.
        hostPubkey =
          let
            se = ../../../secrets/master/se.pub;
            dev = ../../../secrets/master/dev.pub;
            host = ../../../secrets/hosts/${config.networking.hostName}.pub;

            # Helper to extract the age1... address from a file
            extractAge1 =
              path:
              let
                content = builtins.readFile path;
                # Matches 'age1...' or 'AGE-PLUGIN-SE-...' (though age1 is preferred for -r)
                # For SE, we specifically want the line that starts with 'age1'
                matches = builtins.match ".*(age1[a-z0-9]+).*" content;
              in
              if matches != null then lib.head matches else null;

            # Helper to get a clean public key (no comments)
            cleanPubKey =
              path:
              let
                age1 = extractAge1 path;
              in
              if age1 != null then
                age1
              else
                # Fallback to reading the first non-comment line if no age1 found
                let
                  content = builtins.readFile path;
                  lines = lib.splitString "\n" content;
                  nonCommentLines = lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) lines;
                in
                lib.head nonCommentLines;
          in
          if isDarwin then
            if builtins.pathExists se then
              cleanPubKey se
            else
              "age10000000000000000000000000000000000000000000000000000000000"
          else if builtins.pathExists dev then
            cleanPubKey dev
          else if builtins.pathExists host then
            cleanPubKey host
          else
            "age10000000000000000000000000000000000000000000000000000000000";
      };

      # Use the identity for decrypting secrets
      age.identityPaths =
        if isDarwin then
          [ ]
        else if config.age.secrets ? host-ssh-key then
          [ config.age.secrets.host-ssh-key.path ]
        else
          [ ];
    })
  ];
}

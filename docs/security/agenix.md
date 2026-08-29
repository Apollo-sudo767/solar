# Encrypted Secrets with Agenix 🔐

Solar manages private tokens, passwords, and SSH keys using **Agenix** and **Agenix-Rekey**, backed by asymmetric Age encryption.

______________________________________________________________________

## 🏛️ Secret Architecture

- **Private Secrets Repository**: Encrypted secrets are stored in the private submodule/repository `solar-secrets`.
- **Public Key Rekeying**: When a new host is deployed, `agenix-rekey` re-encrypts all secrets for the target host's public SSH key without exposing master private keys.
- **Zero-Secret Mode**: Standalone hosts (`useSolarSecrets = false`) boot and operate without needing access to private secrets.

______________________________________________________________________

## 🔑 Seeding Master Keys from Bitwarden

Solar includes custom CLI shortcuts to safely decrypt master Age keys into volatile RAM:

```bash
# Seed master key into /run/user/$UID/agenix-key from Bitwarden
seed

# Perform secret rekeying across the fleet
nix run .#agenix-rekey-rekey

# Securely wipe key from RAM
unseed
```

______________________________________________________________________

## 📝 Referencing Secrets in Modules

```nix
age.secrets."my-service-token" = {
  rekeyFile = "${inputs.solar-secrets}/secrets/my-service-token.age";
  owner = "apollo";
  group = "users";
  mode = "0400";
};
```

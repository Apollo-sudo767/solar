# solar justfile

# Generate new secrets (like host SSH keys)
generate:
    nix run .#agenix-rekey-generate

# Rekey all secrets for all hosts
rekey:
    nix run .#agenix-rekey-rekey

# Rekey secrets for a specific host
rekey-host host:
    nix run .#agenix-rekey-rekey -- --host {{host}}

# Edit a master secret
edit secret:
    nix run .#agenix-rekey-edit -- {{secret}}

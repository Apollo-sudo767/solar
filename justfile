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

# Bootstrap a new host by pushing its managed SSH key
bootstrap host ip:
    nix run .#agenix-rekey-edit -- secrets/hosts/{{host}}.age | ssh {{ip}} "sudo mkdir -p /etc/ssh && sudo tee /etc/ssh/ssh_host_ed25519_key > /dev/null && sudo chmod 600 /etc/ssh/ssh_host_ed25519_key && sudo systemctl restart sshd"

# Install NixOS on a fresh machine with injected secrets
install host ip:
    #!/usr/bin/env bash
    set -euo pipefail
    EXTRA_FILES=$(mktemp -d)
    trap 'rm -rf "$EXTRA_FILES"' EXIT
    mkdir -p "$EXTRA_FILES/persist/etc/ssh"
    echo "Decrypting managed host key for {{host}}..."
    nix run .#agenix-rekey-edit -- "secrets/hosts/{{host}}.age" > "$EXTRA_FILES/persist/etc/ssh/ssh_host_ed25519_key"
    chmod 600 "$EXTRA_FILES/persist/etc/ssh/ssh_host_ed25519_key"
    echo "Running nixos-anywhere..."
    nix run github:numtide/nixos-anywhere -- --extra-files "$EXTRA_FILES" --flake ".#{{host}}" "root@{{ip}}"

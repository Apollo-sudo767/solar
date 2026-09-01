# Networking & Mesh VPN 🌐

Solar connects all personal computers, mobile laptops, and headless servers across a secure, zero-trust overlay mesh.

______________________________________________________________________

## 🔒 1. Tailscale Private Mesh VPN (`tailscale.nix`)

- **Subnet Routing & Mesh Access**: Seamless point-to-point WireGuard mesh between all machines in the Solar constellation without port forwarding.
- **Tailscale SSH**: Keyless, cryptographic SSH terminal access between authenticated hosts.
- **Trusted Interfaces**: Firewall automatically trusts `tailscale0` interface across servers (`mars`, `venus`, `ganymede`).

______________________________________________________________________

## 🌐 2. Dynamic DNS & Reverse Proxy (`nginx.nix` & `ddns.nix`)

- **Nginx Reverse Proxy**: Production web server with automatic TLS certificate issuance and renewal via **Lego** ACME client.
- **Automated Cloudflare DDNS**: Background service automatically synchronizing external public IPv4/IPv6 addresses with DNS records for:
  - `joplin.apollan.cc`
  - `zotero.apollan.cc`
  - `languagetool.apollan.cc`
  - `factorio.apollan.cc`
  - `nomansland.apollan.cc`

______________________________________________________________________

## 🔄 3. Continuous P2P Sync (`syncthing.nix`)

- Peer-to-peer file synchronization between workstations and storage servers.
- Bound securely to localhost (`127.0.0.1:8384`) and accessible over Tailscale.
- State and folder configurations preserved on persistent Btrfs storage.

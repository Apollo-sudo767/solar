# Security & Hardening 🛡️

Solar implements a multi-layered security strategy protecting the entire stack from firmware execution to user space.

______________________________________________________________________

## 🔐 1. LUKS Disk Encryption

Full disk encryption is configured on all storage partitions when `enableLuks = true`.

### The Same-Passphrase Rule:

> [!IMPORTANT]
> **Always set the identical LUKS passphrase across all encrypted drives in a multi-disk system.**
> `systemd-cryptsetup` in `initrd` caches the password from the first drive and re-uses it across all remaining drives. This enables single-prompt booting and prevents headless/automated reboots from getting stuck.

To synchronize passphrases across drives:

```bash
sudo cryptsetup luksAddKey /dev/sda1
sudo cryptsetup luksAddKey /dev/sdb1
```

______________________________________________________________________

## 🛡️ 2. Native Secure Boot with Limine (`sbctl`)

1. Put UEFI into **Setup Mode** in BIOS.
1. Generate private platform keys:
   ```bash
   sudo sbctl create-keys
   ```
1. Enroll custom keys alongside Microsoft OEM certificates:
   ```bash
   sudo sbctl enroll-keys --microsoft
   ```
1. Sign the bootloader and kernels:
   ```bash
   sudo find /boot -type f -name "*.efi" -exec sbctl sign -s {} +
   sudo find /boot -type f \( -name "vmlinuz*" -o -name "bzImage*" \) -exec sbctl sign -s {} +
   ```
1. Enable automated signing on future rebuilds in `modules/hosts/<hostname>/default.nix`:
   ```nix
   myFeatures.core.boot.secureBoot.enable = true;
   ```

______________________________________________________________________

## 🔑 3. TPM 2.0 Tamper-Proof Auto-Unlock

Bind LUKS encryption keys to TPM registers **PCR 0** (firmware) + **PCR 7** (Secure Boot state):

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
```

- **Trusted Boot**: Secure Boot verifies the signed kernel $\\rightarrow$ TPM releases key $\\rightarrow$ Machine boots automatically without password prompts.
- **Untrusted / Tampered Boot**: If firmware is altered, Secure Boot is turned off, or an unauthorized kernel is booted $\\rightarrow$ TPM locks down $\\rightarrow$ Prompts for the manual LUKS recovery passphrase.

______________________________________________________________________

## 🧱 4. Host Hardening & Isolation

- **AppArmor MAC**: Mandatory Access Control profiles enforced across services (`useAppArmor = true`).
- **Kernel Protection**: `protectKernelImage = true`, `forcePageTableIsolation = true`, and memory allocation checks (`MALLOC_CHECK_=1`).
- **Firewall & Fail2ban**: Default-drop firewall policy with `fail2ban` protecting SSH and exposed ports.
- **Secret Separation**: Standalone hosts set `useSolarSecrets = false` and `security.agenix.enable = false` to run fully self-contained without requiring private secret submodules.

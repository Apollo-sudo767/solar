# TPM 2.0 Tamper-Proof Auto-Unlock 🔑

By pairing **LUKS encryption** with **Secure Boot** through the **TPM 2.0** chip, the system can automatically unlock encrypted drives on boot **without prompting for a password**—while remaining completely secure against tampering.

______________________________________________________________________

## ⚙️ How it Works

- We bind the LUKS encryption key to TPM registers **PCR 0** (motherboard firmware) and **PCR 7** (Secure Boot state & signed certificate database).
- **Normal Boot:** Secure Boot verifies the signed Limine bootloader and signed kernel $\\rightarrow$ PCR 7 matches $\\rightarrow$ TPM releases LUKS key $\\rightarrow$ System boots seamlessly without password prompts.
- **Tampered Boot:** If an attacker modifies the kernel, disables Secure Boot, boots a live USB, or moves the drive to another machine $\\rightarrow$ PCR 7 measurement changes $\\rightarrow$ TPM **refuses** to release the key $\\rightarrow$ System demands the manual LUKS recovery passphrase.

______________________________________________________________________

## 🛠️ Enrolling TPM 2.0 on Encrypted Partitions

Run `systemd-cryptenroll` on each encrypted disk partition:

```bash
# 1. Primary OS / Speed Drive:
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2

# 2. Bulk Storage Drives (e.g. on NAS / Storage hosts):
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/sda1
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/sdb1
```

______________________________________________________________________

## 🔍 Verifying TPM 2.0 Enrollment

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2
```

*(You will see a `systemd-tpm2` token listed alongside your manual passphrase keyslot.)*

> [!TIP]
> If a future motherboard firmware update changes PCR 0 and causes TPM unlock to fail, simply enter your manual recovery passphrase at boot, then re-enroll the TPM with:
>
> ```bash
> sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
> ```

# 🔐 Secure PGP Key Generation with YubiKey Support

This project provides a Bash script and step-by-step guide for securely generating a **PGP key hierarchy** using **modern elliptic curve cryptography** (ed25519, cv25519), ready for use with a **YubiKey 5C NFC**.

Keys are generated in an **offline GPG environment**, and private subkeys are later moved onto the YubiKey.

---

## ✅ Prerequisites

- A Linux system (tested on Ubuntu/Debian)
- Internet connection (for initial package install)
- A **YubiKey 5C NFC**
- Basic familiarity with GPG

---

## 📂 How to Use This Script

### 1. Download the Script

Clone this repository or download just the script:

```bash
curl -O https://raw.githubusercontent.com/leemw1977/generate-pgp-keys/generate.sh
```

Or if you've cloned the repo:

```bash
cd generate-pgp-keys/
```


---

### 2. Make It Executable

```bash
chmod +x generate.sh
```

---

### 3. Run the Script

```bash
./generate-pgp-keys.sh
```

The script will:

- Install required GPG and YubiKey tools
- Set up a clean offline GPG environment in `~/gnupg-offline`
- Launch `gpg --full-generate-key` for you to:
  - Choose **ECC → Curve 25519 (ed25519)**
  - Set usage to **Certification only**
  - Enter your name, email, and expiry
- Prompt you to add subkeys interactively

---

## 🧭 What Happens After Running

After the script finishes:

1. You'll see your **key ID or fingerprint**, which you copy for use.
2. You'll be inside the `gpg --edit-key` prompt:
   - Add three subkeys interactively:
     ```gpg
     gpg> addkey         # signing subkey (ed25519)
     gpg> addkey         # encryption subkey (cv25519)
     gpg> addkey         # authentication subkey (ed25519)
     gpg> save
     ```
   - For each `addkey`:
     - Select **ECC**
     - Use **Curve 25519**
     - Enable only the relevant usage flag (S / E / A)

You now have a modern key hierarchy ready to use and transfer to a YubiKey.

---

## 🧑‍💼 What To Do Next (Manual Steps)

### 🔑 1. Transfer Subkeys to YubiKey

Insert your YubiKey and run:

```bash
gpg --edit-key <KEYID>
```

Then for each subkey:

```gpg
gpg> toggle
gpg> key <N>        # select subkey number
gpg> keytocard
```

Choose appropriate slots when prompted:
- **Signature** slot for signing key
- **Encryption** slot for encryption key
- **Authentication** slot for auth key

Then:
```gpg
gpg> save
```

---

### 📦 2. Export Keys and Revocation Certificate

```bash
# Export your public key
gpg --armor --export > public-key.asc

# Export secret subkeys (optional encrypted backup)
gpg --armor --export-secret-subkeys > secret-subkeys.asc

# Create revocation certificate
gpg --output revoke.asc --gen-revoke <KEYID>
```

> 💡 Store `secret-subkeys.asc` and `revoke.asc` in a secure encrypted USB or offline medium.

---

### 🧹 3. Clean Up Offline Environment (Optional)

If you’re done and have backed up securely:

```bash
rm -rf ~/gnupg-offline
```

You can now import just your **public key** into your normal GPG setup for everyday use.

---

## 🔒 Summary

- ✔️ You now have a **cert-only master key** (ed25519)
- ✔️ You generated subkeys for:
  - **Signing** (ed25519)
  - **Encryption** (cv25519)
  - **Authentication** (ed25519)
- 🔐 Subkeys are **moved to your YubiKey** (not stored on disk)
- 💾 Backup of master key + revoke certificate completed

This is a modern, secure, and YubiKey-compatible setup suitable for Git signing, SSH, email encryption, and MFA workflows.

---

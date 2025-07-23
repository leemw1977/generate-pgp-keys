#!/bin/bash
set -e

# Step 1: Install dependencies
echo "[+] Installing required packages..."
sudo apt update
sudo apt install -y gnupg2 gnupg-agent scdaemon pcscd \
  pinentry-gtk2 yubikey-manager

# Step 2: Set up temporary offline GPG directory
echo "[+] Creating offline GPG environment..."
export GNUPGHOME="$HOME/gnupg-offline"
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

# Step 3: Generate Master (certification-only) key
echo "[+] Generating master key (certification-only)..."
echo "⚠️ You will be prompted for key type, name, email, and expiry."
echo "📌 Select: ECC -> Curve 25519 (ed25519)"
echo "📌 Usage: Certification only (uncheck sign/encrypt/auth)"
echo
read -p "Press Enter to launch key generation..."

gpg --full-generate-key

# Step 4: List key ID
echo "[+] Your keys so far:"
gpg --list-keys

echo
read -p "🔑 Enter your master key ID (e.g. ABCD1234 or full fingerprint): " KEYID

# Step 5: Add subkeys
echo "[+] Launching GPG edit session to add subkeys..."
echo "📌 You will add 3 subkeys: sign (ed25519), encrypt (cv25519), auth (ed25519)"
echo "📌 Each time, use: 'addkey' -> ECC -> Curve 25519"
echo "📌 Choose key usage as needed (sign, encrypt, auth)."
echo
read -p "Press Enter to begin..."

gpg --edit-key "$KEYID"

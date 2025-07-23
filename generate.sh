#!/bin/bash
set -e

# Function to detect package manager
detect_package_manager() {
  if command -v apt &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  else
    echo "Unsupported distribution. Please install dependencies manually." >&2
    exit 1
  fi
}

# Step 1: Install dependencies
PACKAGE_MANAGER=$(detect_package_manager)
echo "[+] Detected package manager: $PACKAGE_MANAGER"
echo "[+] Installing required packages..."

if [ "$PACKAGE_MANAGER" = "apt" ]; then
  sudo apt update
  sudo apt install -y gnupg2 gnupg-agent scdaemon pcscd     pinentry-gtk2 yubikey-manager
elif [ "$PACKAGE_MANAGER" = "dnf" ]; then
  sudo dnf install -y gnupg2 gnupg2-smime gnupg2-curl pcsc-lite     pinentry-gtk yubikey-manager
fi

# Step 1.5: Optionally allow user to disconnect wi-fi
echo
echo "⚠️  Packages have been installed."
echo "🛑  Now is a good time to disconnect from Wi-Fi or Ethernet for extra key generation security."
read -p "🔌 Disconnect from the network now and press Enter to continue..."

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

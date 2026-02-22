#!/bin/bash

# Load shared env loader
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/load_env.sh"

# 2. Auto-grab SSH key if not in .env
if [ -z "$MY_PUBLIC_KEY" ]; then
    if [ -f ~/.ssh/id_ed25519.pub ]; then
        MY_PUBLIC_KEY=$(cat ~/.ssh/id_ed25519.pub)
    else
        echo "❌ Error: no ssh id_ed25519.pub key in .env or .ssh folder!"
        exit 1
    fi
fi

TEMPLATE_FILE="user-data.tmp"
FINAL_USER_DATA="user-data"
ISO_NAME="seed.iso"

echo "🔐 Using Tailscale Key: $TAILSCALE_KEY"
echo "🔐 Using SSH Public Key: $MY_PUBLIC_KEY"

echo "🛠 Preparing Cloud-Init ISO..."

# 1. Create an empty meta-data file (Required by cloud-init)
touch meta-data

# 2. Inject the secret key into the user-data file
# Use sed to swap both the Tailscale key and the SSH key
sed -e "s|\${TAILSCALE_KEY}|$TAILSCALE_KEY|g" \
    -e "s|\${MY_PUBLIC_KEY}|$MY_PUBLIC_KEY|g" \
    -e "s|\${VM_USER}|$VM_USER|g" \
    -e "s|\${VM_HOSTNAME}|$VM_HOSTNAME|g" \
    -e "s|\${GIT_NAME}|$GIT_NAME|g" \
    -e "s|\${GIT_EMAIL}|$GIT_EMAIL|g" \
    -e "s|\${CODE_SERVER_PASSWORD}|$CODE_SERVER_PASSWORD|g" \
    -e "s|\${CODE_SERVER_PORT}|$CODE_SERVER_PORT|g" \
    $TEMPLATE_FILE > $FINAL_USER_DATA

rm $ISO_NAME 2>/dev/null || true
# 3. Generate the ISO (Label must be 'cidata' for NoCloud)
# -volid cidata is the magic "standard" cloud-init looks for
mkisofs -output $ISO_NAME -volid cidata -joliet -rock $FINAL_USER_DATA meta-data

# 4. Cleanup temporary text file (to keep secrets out of plain sight)
rm $FINAL_USER_DATA
rm meta-data

echo "✅ Success! Attach '$ISO_NAME' to your VMware Fusion VM as a CD-ROM."

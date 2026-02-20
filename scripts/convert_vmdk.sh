#!/bin/bash

# Load shared env loader
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/load_env.sh"

tar -xzvf $TAR
qemu-img convert -f raw -O vmdk disk.raw $VMDK
rm -f disk.raw
echo "Conversion complete: $VMDK"

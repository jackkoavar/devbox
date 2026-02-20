#!/usr/bin/env bash
set -e

# Determine repository root (one level up from this script)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

if [ -f "$ENV_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
    echo "✅ Loaded $ENV_FILE"
    return 0 2>/dev/null || exit 0
fi

cp "$REPO_ROOT/.env.tmp" "$ENV_FILE"
echo "❌ .env not found. Copied .env.tmp to $ENV_FILE — please edit $ENV_FILE and re-run."
exit 1

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${CONTUBERNIUM_BIN_DIR:-}" ]]; then
    INSTALL_DIR="$CONTUBERNIUM_BIN_DIR"
elif [[ -d "$HOME/bin" ]]; then
    INSTALL_DIR="$HOME/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
fi

echo "🏛️ Building Contubernium..."
(
    cd "$ROOT_DIR"
    zig build
)

mkdir -p "$INSTALL_DIR"
ln -sf "$ROOT_DIR/zig-out/bin/contubernium" "$INSTALL_DIR/contubernium"

echo "✅ Installed contubernium to $INSTALL_DIR/contubernium"

case ":$PATH:" in
    *":$INSTALL_DIR:"*)
        echo "✅ $INSTALL_DIR is already on PATH"
        ;;
    *)
        echo "⚠️ Add this directory to your PATH to use 'contubernium' from any project:"
        echo "   export PATH=\"$INSTALL_DIR:\$PATH\""
        ;;
esac

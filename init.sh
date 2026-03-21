#!/usr/bin/env bash

# Find the absolute path to the directory where this script lives
GLOBAL_BARRACKS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$GLOBAL_BARRACKS/.agents"

echo "🏛️ Deploying Contubernium..."

# 1. Verify the global .agents directory exists
if [ ! -d "$AGENTS_DIR" ]; then
    echo "❌ Error: Agents directory not found at $AGENTS_DIR"
    exit 1
fi

# 2. Create the symlink (safeguarded so it doesn't overwrite existing ones)
if [ -e ".agents" ]; then
    echo "⚠️ .agents symlink already exists in this directory."
else
    ln -s "$AGENTS_DIR" .agents
    echo "✅ Agents symlinked successfully."
fi

# 3. Generate the local state file (safeguarded to protect existing project memory)
if [ -f "contubernium_state.json" ]; then
    echo "⚠️ contubernium_state.json already exists. Skipping to protect state."
else
    cat << 'EOF' > contubernium_state.json
{
  "project_name": "UNASSIGNED",
  "global_status": "idle",
  "current_actor": "decanus",
  "tasks": {
    "backend": { "status": "pending", "assigned_to": "faber", "description": "", "artifacts": [] },
    "frontend": { "status": "pending", "assigned_to": "artifex", "description": "", "artifacts": [] },
    "systems": { "status": "pending", "assigned_to": "architectus", "description": "", "artifacts": [] },
    "qa": { "status": "pending", "assigned_to": "tesserarius", "description": "", "artifacts": [] },
    "research": { "status": "pending", "assigned_to": "explorator", "description": "", "artifacts": [] },
    "brand": { "status": "pending", "assigned_to": "signifer", "description": "", "artifacts": [] },
    "media": { "status": "pending", "assigned_to": "praeco", "description": "", "artifacts": [] },
    "docs": { "status": "pending", "assigned_to": "calo", "description": "", "artifacts": [] },
    "bulk_ops": { "status": "pending", "assigned_to": "mulus", "description": "", "artifacts": [] }
  }
}
EOF
    echo "✅ Local contubernium_state.json initialized."
fi

echo "🚀 Contubernium deployed! Awaiting Decanus orders."

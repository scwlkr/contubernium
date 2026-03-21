#!/usr/bin/env bash

# Find the absolute path to the directory where this script lives
GLOBAL_BARRACKS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$GLOBAL_BARRACKS/.agents"
STATE_TEMPLATE="$GLOBAL_BARRACKS/templates/contubernium_state.template.json"

echo "🏛️ Deploying Contubernium..."

# 1. Verify the global .agents directory exists
if [ ! -d "$AGENTS_DIR" ]; then
    echo "❌ Error: Agents directory not found at $AGENTS_DIR"
    exit 1
fi

# 2. Verify the state template exists
if [ ! -f "$STATE_TEMPLATE" ]; then
    echo "❌ Error: State template not found at $STATE_TEMPLATE"
    exit 1
fi

# 3. Create the symlink (safeguarded so it doesn't overwrite existing ones)
if [ -e ".agents" ]; then
    echo "⚠️ .agents symlink already exists in this directory."
else
    ln -s "$AGENTS_DIR" .agents
    echo "✅ Agents symlinked successfully."
fi

# 4. Generate the local state file (safeguarded to protect existing project memory)
if [ -f "contubernium_state.json" ]; then
    echo "⚠️ contubernium_state.json already exists. Skipping to protect state."
else
    cp "$STATE_TEMPLATE" contubernium_state.json
    echo "✅ Local contubernium_state.json initialized."
fi

echo "🚀 Contubernium deployed! Awaiting Decanus loop orders."

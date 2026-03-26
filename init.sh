#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$PWD}"
CONTUBERNIUM_HOME="${CONTUBERNIUM_HOME:-$HOME/.contubernium}"

require_path() {
    local path="$1"
    local label="$2"
    if [[ ! -e "$path" ]]; then
        echo "error: missing ${label}: $path" >&2
        exit 1
    fi
}

copy_if_missing() {
    local source_path="$1"
    local target_path="$2"

    if [[ -e "$target_path" ]]; then
        return
    fi

    mkdir -p "$(dirname "$target_path")"
    install -m 0644 "$source_path" "$target_path"
}

copy_tree_if_missing() {
    local source_dir="$1"
    local target_dir="$2"
    local source_file
    local relative_path

    while IFS= read -r source_file; do
        relative_path="${source_file#"$source_dir"/}"
        copy_if_missing "$source_file" "$target_dir/$relative_path"
    done < <(find "$source_dir" -type f | sort)
}

template_path() {
    local template_dir="$1"
    local primary_name="$2"
    local fallback_name="$3"

    if [[ -f "$template_dir/$primary_name" ]]; then
        printf '%s\n' "$template_dir/$primary_name"
        return
    fi

    printf '%s\n' "$template_dir/$fallback_name"
}

select_asset_root() {
    if [[ -d "$CONTUBERNIUM_HOME/agents" && -d "$CONTUBERNIUM_HOME/prompts" && -d "$CONTUBERNIUM_HOME/templates" ]]; then
        printf '%s\n' "$CONTUBERNIUM_HOME"
        return
    fi

    printf '%s\n' "$SCRIPT_DIR"
}

ASSET_ROOT="$(select_asset_root)"
AGENTS_SOURCE="$ASSET_ROOT/agents"
PROMPTS_SOURCE="$ASSET_ROOT/prompts"
TEMPLATES_SOURCE="$ASSET_ROOT/templates"

if [[ "$ASSET_ROOT" == "$SCRIPT_DIR" ]]; then
    AGENTS_SOURCE="$SCRIPT_DIR/.agents"
    PROMPTS_SOURCE="$SCRIPT_DIR/prompts"
fi

STATE_TEMPLATE="$(template_path "$TEMPLATES_SOURCE" "state.json" "contubernium_state.template.json")"
CONFIG_TEMPLATE="$(template_path "$TEMPLATES_SOURCE" "config.json" "contubernium.config.template.json")"
PROJECT_TEMPLATE="$(template_path "$TEMPLATES_SOURCE" "project.md" "project.template.md")"
GLOBAL_TEMPLATE="$(template_path "$TEMPLATES_SOURCE" "global.md" "global.template.md")"

require_path "$AGENTS_SOURCE" "agents source"
require_path "$PROMPTS_SOURCE" "prompts source"
require_path "$STATE_TEMPLATE" "state template"
require_path "$CONFIG_TEMPLATE" "config template"
require_path "$PROJECT_TEMPLATE" "project memory template"
require_path "$GLOBAL_TEMPLATE" "global memory template"

mkdir -p "$PROJECT_DIR/.contubernium/logs"
mkdir -p "$PROJECT_DIR/.agents"

copy_if_missing "$STATE_TEMPLATE" "$PROJECT_DIR/.contubernium/state.json"
copy_if_missing "$CONFIG_TEMPLATE" "$PROJECT_DIR/.contubernium/config.json"
copy_if_missing "$PROJECT_TEMPLATE" "$PROJECT_DIR/.contubernium/project.md"
copy_if_missing "$GLOBAL_TEMPLATE" "$PROJECT_DIR/.contubernium/global.md"
copy_tree_if_missing "$PROMPTS_SOURCE" "$PROJECT_DIR/.contubernium/prompts"
copy_tree_if_missing "$AGENTS_SOURCE" "$PROJECT_DIR/.agents"

echo "Initialized Contubernium in $PROJECT_DIR"
echo "  - $PROJECT_DIR/.contubernium"
echo "  - $PROJECT_DIR/.agents"

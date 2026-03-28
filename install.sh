#!/usr/bin/env bash
set -euo pipefail

DEFAULT_REPO_URL="https://github.com/scwlkr/contubernium.git"
DEFAULT_REPO_REF="main"
CONTUBERNIUM_HOME="${CONTUBERNIUM_HOME:-$HOME/.contubernium}"

require_command() {
    local command_name="$1"
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "error: required command not found: $command_name" >&2
        exit 1
    fi
}

path_contains() {
    local candidate="$1"
    case ":$PATH:" in
        *":$candidate:"*) return 0 ;;
        *) return 1 ;;
    esac
}

pick_install_dir() {
    if [[ -n "${CONTUBERNIUM_BIN_DIR:-}" ]]; then
        printf '%s\n' "$CONTUBERNIUM_BIN_DIR"
        return
    fi

    if path_contains "$HOME/.local/bin"; then
        printf '%s\n' "$HOME/.local/bin"
        return
    fi

    if path_contains "$HOME/bin"; then
        printf '%s\n' "$HOME/bin"
        return
    fi

    if [[ -d "$HOME/.local/bin" ]]; then
        printf '%s\n' "$HOME/.local/bin"
        return
    fi

    if [[ -d "$HOME/bin" ]]; then
        printf '%s\n' "$HOME/bin"
        return
    fi

    printf '%s\n' "$HOME/.local/bin"
}

detect_shell_rc() {
    local shell_name
    shell_name="$(basename "${SHELL:-}")"

    case "$shell_name" in
        zsh)
            printf '%s\n' "$HOME/.zshrc"
            ;;
        bash)
            if [[ -f "$HOME/.bash_profile" ]]; then
                printf '%s\n' "$HOME/.bash_profile"
            else
                printf '%s\n' "$HOME/.bashrc"
            fi
            ;;
        *)
            printf '\n'
            ;;
    esac
}

is_repo_root() {
    local candidate="$1"
    [[ -f "$candidate/build.zig" && -f "$candidate/build.zig.zon" && -d "$candidate/src" ]]
}

prepare_managed_source() {
    local source_dir="$CONTUBERNIUM_HOME/source"
    local repo_url="${CONTUBERNIUM_REPO_URL:-$DEFAULT_REPO_URL}"
    local repo_ref="${CONTUBERNIUM_REF:-$DEFAULT_REPO_REF}"

    require_command git
    mkdir -p "$CONTUBERNIUM_HOME"

    if [[ -d "$source_dir/.git" ]]; then
        echo "Updating managed source checkout in $source_dir" >&2
        git -C "$source_dir" fetch --depth 1 origin "$repo_ref"
        if git -C "$source_dir" show-ref --verify --quiet "refs/heads/$repo_ref"; then
            git -C "$source_dir" checkout "$repo_ref"
        else
            git -C "$source_dir" checkout -b "$repo_ref" --track "origin/$repo_ref"
        fi
        git -C "$source_dir" merge --ff-only "origin/$repo_ref"
    else
        echo "Cloning Contubernium into $source_dir" >&2
        git clone --depth 1 --branch "$repo_ref" "$repo_url" "$source_dir"
    fi

    printf '%s\n' "$source_dir"
}

pick_source_dir() {
    if [[ -n "${CONTUBERNIUM_SOURCE_DIR:-}" ]]; then
        local provided_source
        provided_source="$(cd "$CONTUBERNIUM_SOURCE_DIR" && pwd)"
        if ! is_repo_root "$provided_source"; then
            echo "error: CONTUBERNIUM_SOURCE_DIR is not a Contubernium repository: $provided_source" >&2
            exit 1
        fi
        printf '%s\n' "$provided_source"
        return
    fi

    local script_path="${BASH_SOURCE[0]-}"
    if [[ -n "$script_path" && "$script_path" != "bash" && "$script_path" != "-bash" ]]; then
        local script_dir
        script_dir="$(cd "$(dirname "$script_path")" && pwd)"
        if is_repo_root "$script_dir"; then
            printf '%s\n' "$script_dir"
            return
        fi
    fi

    prepare_managed_source
}

copy_tree() {
    local source_dir="$1"
    local target_dir="$2"
    mkdir -p "$target_dir"
    cp -R "$source_dir/." "$target_dir/"
}

install_global_assets() {
    local source_dir="$1"
    local home_dir="$2"
    local templates_dir="$home_dir/templates"

    mkdir -p "$home_dir" "$templates_dir"
    copy_tree "$source_dir/.agents" "$home_dir/agents"
    copy_tree "$source_dir/shared" "$home_dir/shared"
    copy_tree "$source_dir/adapters" "$home_dir/adapters"
    copy_tree "$source_dir/opentui" "$home_dir/opentui"

    install -m 0644 "$source_dir/templates/contubernium_state.template.json" "$templates_dir/state.json"
    install -m 0644 "$source_dir/templates/contubernium.config.template.json" "$templates_dir/config.json"
    install -m 0644 "$source_dir/templates/project.template.md" "$templates_dir/project.md"
    install -m 0644 "$source_dir/templates/global.template.md" "$templates_dir/global.md"
    install -m 0644 "$source_dir/templates/architecture.template.md" "$templates_dir/architecture.md"
    install -m 0644 "$source_dir/templates/plan.template.md" "$templates_dir/plan.md"
    install -m 0644 "$source_dir/templates/project_context.template.md" "$templates_dir/project_context.md"

    if [[ ! -f "$home_dir/global.md" ]]; then
        install -m 0644 "$source_dir/templates/global.template.md" "$home_dir/global.md"
    fi

    if [[ -d "$home_dir/agents/skills" ]]; then
        rm -rf "$home_dir/agents/skills"
    fi

    echo "Installing OpenTUI frontend dependencies in $home_dir/opentui" >&2
    (
        cd "$home_dir/opentui"
        bun install --frozen-lockfile
    )
}

INSTALL_DIR="$(pick_install_dir)"
SOURCE_DIR="$(pick_source_dir)"

require_command zig
require_command bun

echo "Building Contubernium from $SOURCE_DIR"
(
    cd "$SOURCE_DIR"
    zig build
)

mkdir -p "$INSTALL_DIR"
install -m 0755 "$SOURCE_DIR/zig-out/bin/contubernium" "$INSTALL_DIR/contubernium"
install_global_assets "$SOURCE_DIR" "$CONTUBERNIUM_HOME"

echo "Installed contubernium to $INSTALL_DIR/contubernium"
echo "Installed Contubernium home to $CONTUBERNIUM_HOME"

if path_contains "$INSTALL_DIR"; then
    echo "$INSTALL_DIR is already on PATH"
else
    SHELL_RC="$(detect_shell_rc)"
    if [[ -n "$SHELL_RC" ]]; then
        echo "Add this line to $SHELL_RC to use 'contubernium' from any project:"
    else
        echo "Add this line to your shell profile to use 'contubernium' from any project:"
    fi
    echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo "Next steps:"
echo "  1. Start Ollama or your configured local backend."
echo "  2. Run 'contubernium init' inside a project."
echo "  3. Edit '.contubernium/config.json' for provider settings if needed."

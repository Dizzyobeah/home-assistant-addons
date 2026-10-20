#!/usr/bin/with-contenv bashio

# Gemini Terminal: the OpenCode agent in a browser terminal (ttyd + tmux), using
# Google Gemini as its only LLM backend.
#
# Startup philosophy: everything the terminal needs is baked into the image,
# and nothing on the boot path may depend on the network or block on input.

set -e
set -o pipefail

# HOME and XDG dirs live in /data so OpenCode sessions and settings persist
init_environment() {
    export HOME="/data/home"
    export XDG_CONFIG_HOME="/data/.config"
    export XDG_CACHE_HOME="/data/.cache"
    export XDG_STATE_HOME="/data/.local/state"
    export XDG_DATA_HOME="/data/.local/share"

    if ! mkdir -p "$HOME" "$XDG_CONFIG_HOME/opencode" "$XDG_CACHE_HOME" "$XDG_STATE_HOME" "$XDG_DATA_HOME"; then
        bashio::log.error "Failed to create directories in /data"
        exit 1
    fi

    cp /opt/scripts/tmux.conf "$HOME/.tmux.conf"

    bashio::log.info "Environment initialized (HOME=${HOME})"
}

# Install user-facing commands into /usr/local/bin
setup_commands() {
    local entry name script
    for entry in \
        "welcome:/opt/scripts/welcome.sh" \
        "persist-install:/opt/scripts/persist-install.sh" \
        "ha-context:/opt/scripts/ha-context.sh"; do
        name="${entry%%:*}"
        script="${entry#*:}"
        cp "$script" "/usr/local/bin/$name"
        chmod +x "/usr/local/bin/$name"
    done

    # Add-on version for the welcome banner (no bashio inside ttyd)
    bashio::addon.version > /opt/scripts/addon-version 2>/dev/null \
        || echo "unknown" > /opt/scripts/addon-version
}

# The API key reaches OpenCode through the environment only (the config file
# references it as {env:GEMINI_API_KEY}), so it never lands in /data or backups.
# The value itself is never logged.
export_gemini_env() {
    export GEMINI_API_KEY
    GEMINI_API_KEY=$(bashio::config 'gemini_api_key')
    GEMINI_MODEL=$(bashio::config 'gemini_model' 'gemini-flash-latest')
    GEMINI_SMALL_MODEL=$(bashio::config 'gemini_small_model' 'gemini-flash-lite-latest')
    bashio::log.info "Using Gemini model ${GEMINI_MODEL} (small: ${GEMINI_SMALL_MODEL})"
}

# Warn early (in the add-on log) if Google rejects the key or the model id.
# Background: a slow network must never delay the terminal.
check_gemini() {
    (
        if curl -fsS -m 10 -o /dev/null -H "x-goog-api-key: ${GEMINI_API_KEY}" \
            "https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}"; then
            bashio::log.info "Gemini API key accepted and model ${GEMINI_MODEL} found"
        else
            bashio::log.warning "Gemini API rejected the key or model '${GEMINI_MODEL}'; check gemini_api_key and gemini_model"
        fi
    ) &
}

# Install persistent packages from config and saved state
install_persistent_packages() {
    local persist_config="/data/persistent-packages.json"
    local apk_packages=""
    local pip_packages=""

    if bashio::config.has_value 'persistent_apk_packages'; then
        apk_packages=$(bashio::config 'persistent_apk_packages')
    fi
    if bashio::config.has_value 'persistent_pip_packages'; then
        pip_packages=$(bashio::config 'persistent_pip_packages')
    fi

    if [ -f "$persist_config" ]; then
        apk_packages="$apk_packages $(jq -r '.apk_packages | join(" ")' "$persist_config" 2>/dev/null || true)"
        pip_packages="$pip_packages $(jq -r '.pip_packages | join(" ")' "$persist_config" 2>/dev/null || true)"
    fi

    # Trim whitespace and remove duplicates
    apk_packages=$(echo "$apk_packages" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)
    pip_packages=$(echo "$pip_packages" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

    if [ -n "$apk_packages" ]; then
        bashio::log.info "Installing persistent APK packages: $apk_packages"
        # shellcheck disable=SC2086
        apk add --no-cache $apk_packages || bashio::log.warning "Some APK packages failed to install"
    fi

    if [ -n "$pip_packages" ]; then
        bashio::log.info "Installing persistent pip packages: $pip_packages"
        # shellcheck disable=SC2086
        pip3 install --break-system-packages --no-cache-dir $pip_packages \
            || bashio::log.warning "Some pip packages failed to install"
    fi
}

# Generate the Home Assistant context file (background: a slow Supervisor
# API must never delay the terminal)
generate_ha_context() {
    if [ "$(bashio::config 'ha_smart_context' 'true')" != "true" ]; then
        bashio::log.info "HA Smart Context disabled in configuration"
        return 0
    fi
    bashio::log.info "Generating Home Assistant context in background"
    (/usr/local/bin/ha-context >/dev/null 2>&1 || true) &
}

setup_ha_mcp() {
    # shellcheck source=scripts/setup-ha-mcp.sh
    source /opt/scripts/setup-ha-mcp.sh
    configure_ha_mcp_server || bashio::log.warning "ha-mcp setup encountered issues but continuing..."
}

# Directory the session starts in. Defaults to /config; a typo'd path must
# never take the terminal down.
get_working_directory() {
    local dir
    dir=$(bashio::config 'working_directory' '')
    if [ -z "$dir" ] || [ "$dir" = "null" ]; then
        echo "/config"
    elif [ -d "$dir" ]; then
        echo "$dir"
    else
        bashio::log.warning "working_directory '$dir' does not exist; starting in /config instead"
        echo "/config"
    fi
}

start_web_terminal() {
    local port=7681 session_command workdir

    if [ "$(bashio::config 'auto_launch' 'true')" = "true" ]; then
        session_command="opencode"
    else
        # Shell mode: banner + interactive bash, still inside tmux for
        # reconnect persistence. Run 'opencode' manually when ready.
        session_command="/usr/local/bin/welcome --shell"
    fi
    workdir=$(get_working_directory)

    bashio::log.info "Starting web terminal on port ${port}"

    local ttyd_theme='{"background":"#1a1b26","foreground":"#c0caf5","cursor":"#7aa2f7","cursorAccent":"#1a1b26","selectionBackground":"#33467c","selectionForeground":"#c0caf5","black":"#15161e","red":"#f7768e","green":"#9ece6a","yellow":"#e0af68","blue":"#7aa2f7","magenta":"#bb9af7","cyan":"#7dcfff","white":"#a9b1d6","brightBlack":"#414868","brightRed":"#f7768e","brightGreen":"#9ece6a","brightYellow":"#e0af68","brightBlue":"#7aa2f7","brightMagenta":"#bb9af7","brightCyan":"#7dcfff","brightWhite":"#c0caf5"}'

    # tmux -A attaches to the live session on browser reconnects and HA
    # navigation instead of stacking new ones.
    exec ttyd \
        --port "${port}" \
        --interface 0.0.0.0 \
        --writable \
        --ping-interval 30 \
        --client-option enableReconnect=true \
        --client-option reconnect=10 \
        --client-option reconnectInterval=5 \
        --client-option "theme=${ttyd_theme}" \
        --client-option fontSize=14 \
        tmux new-session -A -s gemini -c "$workdir" "$session_command"
}

main() {
    bashio::log.info "Starting Gemini Terminal add-on..."

    # shellcheck source=scripts/opencode-config.sh
    source /opt/scripts/opencode-config.sh

    init_environment
    export_gemini_env
    write_opencode_config "$XDG_CONFIG_HOME/opencode/opencode.json" "$GEMINI_MODEL" "$GEMINI_SMALL_MODEL"
    check_gemini
    setup_commands
    install_persistent_packages
    generate_ha_context
    setup_ha_mcp
    start_web_terminal
}

main "$@"

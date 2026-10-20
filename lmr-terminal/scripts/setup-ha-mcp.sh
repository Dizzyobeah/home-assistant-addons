#!/usr/bin/with-contenv bashio
# Register ha-mcp (Home Assistant MCP Server) in OpenCode's config
# Repository: https://github.com/homeassistant-ai/ha-mcp

configure_ha_mcp_server() {
    local config_file="$XDG_CONFIG_HOME/opencode/opencode.json"

    if [ "$(bashio::config 'enable_ha_mcp' 'true')" != "true" ]; then
        bashio::log.info "ha-mcp integration is disabled in configuration"
        return 0
    fi

    if [ -z "${SUPERVISOR_TOKEN:-}" ]; then
        bashio::log.warning "SUPERVISOR_TOKEN not available - ha-mcp setup skipped"
        return 0
    fi

    local version tmp
    version=$(bashio::config 'ha_mcp_version' '7.11.0')

    # ha-mcp >= 4.x requires CPython 3.13 exactly, which no Alpine release
    # ships; uv provisions a managed musl 3.13 build (persisted under /data
    # via XDG_DATA_HOME, so it downloads once).
    # --index-strategy unsafe-best-match: the HA wheels index doesn't carry
    # every version, so let uv consider all indexes.
    #
    # HOMEASSISTANT_TOKEN is the literal {env:SUPERVISOR_TOKEN}: OpenCode
    # substitutes it at launch, keeping the token out of the on-disk config
    # (and out of HA backups). tmux.conf keeps SUPERVISOR_TOKEN on re-attach.
    tmp=$(mktemp "${config_file}.XXXXXX")
    if jq --arg pkg "ha-mcp@${version}" '.mcp["home-assistant"] = {
            type: "local",
            command: ["uvx", "--python", "3.13", "--index-strategy", "unsafe-best-match", $pkg],
            environment: {
                HOMEASSISTANT_URL: "http://supervisor/core",
                HOMEASSISTANT_TOKEN: "{env:SUPERVISOR_TOKEN}"
            },
            enabled: true
        }' "$config_file" > "$tmp" && mv "$tmp" "$config_file"; then
        bashio::log.info "ha-mcp ${version} configured for OpenCode"

        # Pre-warm the uv environment so the first MCP connection doesn't
        # hit the client startup timeout
        (uvx --python 3.13 --index-strategy unsafe-best-match \
            --from "ha-mcp@${version}" python -c "" >/dev/null 2>&1 || true) &
        bashio::log.info "Pre-warming ha-mcp environment in background"
    else
        rm -f "$tmp"
        bashio::log.warning "Failed to configure ha-mcp - continuing without MCP integration"
    fi
}

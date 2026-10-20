#!/usr/bin/with-contenv bashio
# Register ha-mcp (Home Assistant MCP Server) in Gemini CLI's settings
# Repository: https://github.com/homeassistant-ai/ha-mcp

configure_ha_mcp_server() {
    if [ "$(bashio::config 'enable_ha_mcp' 'true')" != "true" ]; then
        bashio::log.info "ha-mcp integration is disabled in configuration"
        return 0
    fi

    if [ -z "${SUPERVISOR_TOKEN:-}" ]; then
        bashio::log.warning "SUPERVISOR_TOKEN not available - ha-mcp setup skipped"
        return 0
    fi

    local version
    version=$(bashio::config 'ha_mcp_version' '7.11.0')

    # No pre-warm: installing in the background while Gemini CLI starts ha-mcp
    # ran two installs at once and exhausted RAM on 2 GB hosts. The first
    # launch installs once (persisted under /data); the 10 min MCP timeout
    # covers it.
    if add_ha_mcp "$GEMINI_SETTINGS" "$version"; then
        bashio::log.info "ha-mcp ${version} configured for Gemini CLI (first launch installs it, which takes a few minutes)"
    else
        bashio::log.warning "Failed to configure ha-mcp - continuing without MCP integration"
    fi
}

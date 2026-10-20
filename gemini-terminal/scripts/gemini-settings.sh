#!/bin/bash
# Pure helpers for writing Gemini CLI's settings (no bashio, so they can be
# tested outside the add-on: `bash scripts/gemini-settings.sh --test`).

# Rewritten on every boot so add-on options always win. API-key auth skips the
# login dialog, folder trust is off so /config opens without a prompt, and
# usage statistics and auto-update are off.
# usage: write_gemini_settings <file> <model>
write_gemini_settings() {
    local file="$1" model="$2"
    jq -n --arg model "$model" '{
        model: { name: $model },
        security: {
            auth: { selectedType: "gemini-api-key" },
            folderTrust: { enabled: false }
        },
        general: { enableAutoUpdate: false, enableAutoUpdateNotification: false },
        privacy: { usageStatisticsEnabled: false }
    }' > "$file"
}

# Registers ha-mcp. HOMEASSISTANT_TOKEN is the literal $SUPERVISOR_TOKEN, which
# Gemini CLI expands at launch, keeping the token out of the on-disk settings
# (and out of HA backups). `uv tool install` (a no-op once installed) then exec,
# instead of uvx: uvx stays resident beside ha-mcp at ~300 MB. nice: the first
# launch installs Python 3.13 and ha-mcp, which must not starve Home Assistant.
# usage: add_ha_mcp <file> <version>
add_ha_mcp() {
    local file="$1" version="$2" tmp
    tmp=$(mktemp "${file}.XXXXXX")
    jq --arg pkg "ha-mcp@${version}" '.mcpServers["home-assistant"] = {
        command: "nice",
        args: ["-n", "10", "sh", "-c",
            "uv tool install --quiet --python 3.13 --index-strategy unsafe-best-match \"$0\" >&2 && exec \"$(uv tool dir --bin)/ha-mcp\"",
            $pkg],
        env: {
            HOMEASSISTANT_URL: "http://supervisor/core",
            HOMEASSISTANT_TOKEN: "$SUPERVISOR_TOKEN"
        },
        timeout: 600000
    }' "$file" > "$tmp" && mv "$tmp" "$file" || { rm -f "$tmp"; return 1; }
}

if [[ "${BASH_SOURCE[0]}" == "${0}" && "$1" == "--test" ]]; then
    set -e
    f=$(mktemp)
    GEMINI_API_KEY=gemini_secret SUPERVISOR_TOKEN=sup_secret write_gemini_settings "$f" gemini-flash-latest
    [ "$(jq -r .model.name "$f")" = "gemini-flash-latest" ]
    [ "$(jq -r .security.auth.selectedType "$f")" = "gemini-api-key" ]
    SUPERVISOR_TOKEN=sup_secret add_ha_mcp "$f" 7.11.0
    [ "$(jq -r '.mcpServers["home-assistant"].args[-1]' "$f")" = "ha-mcp@7.11.0" ]
    # The sh -c script must receive the package as $0, not inline
    jq -r '.mcpServers["home-assistant"].args[-2]' "$f" | grep -q '"\$0"'
    [ "$(jq -r .model.name "$f")" = "gemini-flash-latest" ]
    if grep -q -e gemini_secret -e sup_secret "$f"; then echo "secret leaked into settings" >&2; exit 1; fi
    rm -f "$f"
    echo "ok"
fi

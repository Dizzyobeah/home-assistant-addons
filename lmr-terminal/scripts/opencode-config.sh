#!/bin/bash
# Pure helpers for writing OpenCode's config (no bashio, so they can be tested
# outside the add-on: `bash scripts/opencode-config.sh --test`).

# "http://host:8080/" -> "http://host:8080/v1"; an existing /v1 is kept
normalize_lmr_url() {
    local url="${1%/}"
    [[ "$url" == */v1 ]] || url="$url/v1"
    echo "$url"
}

# Rewritten on every boot so add-on options always win. LMR is the only
# provider; small_model keeps title generation on LMR too, and share, web search
# and updates are off so OpenCode never calls out anywhere else.
# usage: write_opencode_config <file> <base_url> <model>
write_opencode_config() {
    local file="$1" base_url="$2" model="$3"
    jq -n --arg url "$base_url" --arg model "$model" '{
        "$schema": "https://opencode.ai/config.json",
        provider: { lmr: {
            npm: "@ai-sdk/openai-compatible",
            name: "LMR",
            options: { baseURL: $url, apiKey: "{env:LMR_API_KEY}" },
            models: { ($model): { name: "LMR (\($model))" } }
        } },
        enabled_providers: ["lmr"],
        model: "lmr/\($model)",
        small_model: "lmr/\($model)",
        share: "disabled",
        websearch: false,
        update: "disable"
    }' > "$file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" && "$1" == "--test" ]]; then
    set -e
    [ "$(normalize_lmr_url http://h:8080)" = "http://h:8080/v1" ]
    [ "$(normalize_lmr_url http://h:8080/)" = "http://h:8080/v1" ]
    [ "$(normalize_lmr_url http://h:8080/v1/)" = "http://h:8080/v1" ]
    f=$(mktemp)
    LMR_API_KEY=lmr_secret write_opencode_config "$f" "http://h:8080/v1" auto
    [ "$(jq -r .provider.lmr.options.baseURL "$f")" = "http://h:8080/v1" ]
    [ "$(jq -r .model "$f")" = "lmr/auto" ]
    if grep -q lmr_secret "$f"; then echo "API key leaked into config" >&2; exit 1; fi
    rm -f "$f"
    echo "ok"
fi

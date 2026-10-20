#!/bin/bash
# Pure helpers for writing OpenCode's config (no bashio, so they can be tested
# outside the add-on: `bash scripts/opencode-config.sh --test`).

# Rewritten on every boot so add-on options always win. Google Gemini is the
# only provider; the model is declared explicitly so ids newer than OpenCode's
# bundled model catalog still work. Share, web search and updates are off.
# usage: write_opencode_config <file> <model> <small_model>
write_opencode_config() {
    local file="$1" model="$2" small_model="$3"
    jq -n --arg model "$model" --arg small "$small_model" '{
        "$schema": "https://opencode.ai/config.json",
        provider: { google: {
            options: { apiKey: "{env:GEMINI_API_KEY}" },
            models: { ($model): {}, ($small): {} }
        } },
        enabled_providers: ["google"],
        model: "google/\($model)",
        small_model: "google/\($small)",
        share: "disabled",
        websearch: false,
        update: "disable"
    }' > "$file"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" && "$1" == "--test" ]]; then
    set -e
    f=$(mktemp)
    GEMINI_API_KEY=gemini_secret write_opencode_config "$f" gemini-flash-latest gemini-flash-lite-latest
    [ "$(jq -r .model "$f")" = "google/gemini-flash-latest" ]
    [ "$(jq -r .small_model "$f")" = "google/gemini-flash-lite-latest" ]
    [ "$(jq -r '.provider.google.models | keys | length' "$f")" = "2" ]
    if grep -q gemini_secret "$f"; then echo "API key leaked into config" >&2; exit 1; fi
    rm -f "$f"
    echo "ok"
fi

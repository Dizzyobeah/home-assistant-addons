# Gemini Terminal

A web terminal in your Home Assistant sidebar running the
[OpenCode](https://opencode.ai) agent, powered by Google Gemini. Nothing has
to run outside Home Assistant: you only need a Gemini API key. Use it to ask
things like "why did my automation stop firing?" and let the agent read your
config, logs and entity states.

## First setup

1. Create an API key at [Google AI Studio](https://aistudio.google.com/apikey).
2. Set `gemini_api_key` on the **Configuration** tab and start the add-on.

The key is passed to OpenCode through the environment only. It's never written
to `/data`, so it doesn't end up in Home Assistant backups.

After starting, check the add-on **Log**: it says whether Google accepted the
key and found the model.

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `gemini_model` | `gemini-flash-latest` | Gemini model for the agent, e.g. `gemini-3.1-pro-preview` for harder problems. |
| `gemini_small_model` | `gemini-flash-lite-latest` | Cheaper model OpenCode uses for session titles. |
| `auto_launch` | `true` | Start OpenCode automatically. When `false`, you get a shell and run `opencode` yourself. |
| `working_directory` | `/config` | Directory the session starts in. |
| `ha_smart_context` | `true` | Writes a Home Assistant summary to `~/.config/opencode/AGENTS.md`, which OpenCode loads in every session. Refresh it with `ha-context`. |
| `enable_ha_mcp` | `true` | Registers [ha-mcp](https://github.com/homeassistant-ai/ha-mcp) so the agent can query and control Home Assistant. |
| `ha_mcp_version` | `7.11.0` | ha-mcp version to run. |
| `persistent_apk_packages` / `persistent_pip_packages` | `[]` | Packages reinstalled on every start. You can also add them from the terminal with `persist-install`. |

## Privacy and cost

Your prompts, plus whatever files, logs and entity states the agent reads, are
sent to Google. On the free tier Google may use that data to improve its
products. Paid usage is billed per token by Google.

## Security


Port 7681 is disabled by default. If you map it, anyone who can reach it gets a
root shell with write access to `/config`. Use the sidebar panel (ingress)
instead.

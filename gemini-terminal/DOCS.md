# Gemini Terminal

A web terminal in your Home Assistant sidebar running Google's
[Gemini CLI](https://github.com/google-gemini/gemini-cli) agent. Nothing has
to run outside Home Assistant: you only need a Gemini API key. Use it to ask
things like "why did my automation stop firing?" and let the agent read your
config, logs and entity states.

## First setup

1. Create an API key at [Google AI Studio](https://aistudio.google.com/apikey).
2. Set `gemini_api_key` on the **Configuration** tab and start the add-on.

The key is passed to Gemini CLI through the environment only. It's never written
to `/data`, so it doesn't end up in Home Assistant backups.

After starting, check the add-on **Log**: it says whether Google accepted the
key and found the model.

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `gemini_model` | `gemini-flash-latest` | Gemini model for the agent, e.g. `gemini-3.1-pro-preview` for harder problems. You can also switch in the terminal with `/model`. |
| `auto_launch` | `true` | Start Gemini CLI automatically. When `false`, you get a shell and run `gemini` yourself. |
| `working_directory` | `/config` | Directory the session starts in. |
| `ha_smart_context` | `true` | Writes a Home Assistant summary to `~/.gemini/GEMINI.md`, which Gemini CLI loads in every session. Refresh it with `ha-context`. |
| `enable_ha_mcp` | `true` | Registers [ha-mcp](https://github.com/homeassistant-ai/ha-mcp) so the agent can query and control Home Assistant. The first launch installs it, which takes a few minutes on a Raspberry Pi. |
| `ha_mcp_version` | `7.11.0` | ha-mcp version to run. |
| `persistent_apk_packages` / `persistent_pip_packages` | `[]` | Packages reinstalled on every start. You can also add them from the terminal with `persist-install`. |

## Memory use

Measured idle: Gemini CLI ~180 MB, ha-mcp ~180 MB more. The first launch
briefly needs ~400 MB extra while it installs ha-mcp. On a 2 GB Raspberry Pi
that is fine; if memory is still tight, set `enable_ha_mcp: false`.

## Privacy and cost

Your prompts, plus whatever files, logs and entity states the agent reads, are
sent to Google. On the free tier Google may use that data to improve its
products. Paid usage is billed per token by Google.

## Security


Port 7681 is disabled by default. If you map it, anyone who can reach it gets a
root shell with write access to `/config`. Use the sidebar panel (ingress)
instead.

# LMR Terminal

A web terminal in your Home Assistant sidebar running the
[OpenCode](https://opencode.ai) agent. Every model request goes to your
[Local Model Router (LMR)](https://github.com/Dizzyobeah/lmr). No other LLM
provider is configured.

## First setup

The add-on won't start until these two options are set:

| Option | Example | Notes |
|--------|---------|-------|
| `lmr_url` | `http://192.168.1.20:8080` | Base URL of LMR. `/v1` is appended automatically if missing. |
| `lmr_api_key` | `lmr_...` | Create one in the LMR admin UI (`<lmr_url>/admin` → **API Keys**). It's shown only once. |

The key is passed to OpenCode through the environment only. It's never written
to `/data`, so it doesn't end up in Home Assistant backups.

After starting, check the add-on **Log**: it says whether LMR was reachable and
whether it accepted the key.

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `lmr_model` | `auto` | Model id sent to LMR. `auto` is LMR's virtual router model. |
| `auto_launch` | `true` | Start OpenCode automatically. When `false`, you get a shell and run `opencode` yourself. |
| `working_directory` | `/config` | Directory the session starts in. |
| `ha_smart_context` | `true` | Writes a Home Assistant summary to `~/.config/opencode/AGENTS.md`, which OpenCode loads in every session. Refresh it with `ha-context`. |
| `enable_ha_mcp` | `true` | Registers [ha-mcp](https://github.com/homeassistant-ai/ha-mcp) so the agent can query and control Home Assistant. |
| `ha_mcp_version` | `7.11.0` | ha-mcp version to run. |
| `persistent_apk_packages` / `persistent_pip_packages` | `[]` | Packages reinstalled on every start. You can also add them from the terminal with `persist-install`. |

## LMR caveats

- **Tool calling:** agent features (editing files, MCP) only work if LMR routes
  to an Ollama model that supports tool calling. If you get plain text back
  where you expected tool use, check which model LMR picked on its admin
  **Requests** page.
- **Context window:** LMR sets Ollama's `num_ctx` (32k by default). The agent
  system prompt plus the MCP tool definitions take up a good part of that. If
  prompts get truncated, set `enable_ha_mcp: false`.
- **Network:** `localhost` inside the add-on is the add-on container, not your
  LMR host. Use the LMR host's IP address or hostname.

## Security

Port 7681 is disabled by default. If you map it, anyone who can reach it gets a
root shell with write access to `/config`. Use the sidebar panel (ingress)
instead.

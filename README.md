# LMR Terminal for Home Assistant

A Home Assistant add-on that gives you a browser terminal with the
[OpenCode](https://opencode.ai) coding agent. Its only LLM backend is your own
[Local Model Router (LMR)](https://github.com/Dizzyobeah/lmr), so every request
goes to your local Ollama models.

## Installation

1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Open the three-dots menu → **Repositories**
3. Add `https://github.com/Dizzyobeah/home-assistant-addons`
4. Install **LMR Terminal**, set `lmr_url` and `lmr_api_key` on the
   **Configuration** tab, and start it

The image is built locally on your Home Assistant host during install, which
takes a few minutes.

See [lmr-terminal/DOCS.md](lmr-terminal/DOCS.md) for all options.

## Credits

Based on [heytcass/home-assistant-addons](https://github.com/heytcass/home-assistant-addons)
(MIT). The terminal agent is OpenCode, and the LLM backend is LMR.

## License

MIT, see [LICENSE](LICENSE).

# LMR Terminal for Home Assistant

Home Assistant add-ons that give you a browser terminal with the
[OpenCode](https://opencode.ai) coding agent:

- **LMR Terminal**: the only LLM backend is your own
  [Local Model Router (LMR)](https://github.com/Dizzyobeah/lmr), so every
  request goes to your local Ollama models.
- **Gemini Terminal**: runs Google's
  [Gemini CLI](https://github.com/google-gemini/gemini-cli) instead of
  OpenCode. Needs nothing but a Gemini API key, and is light enough for a
  2 GB Raspberry Pi.

## Installation

1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Open the three-dots menu → **Repositories**
3. Add `https://github.com/Dizzyobeah/home-assistant-addons`
4. Install **LMR Terminal** (set `lmr_url` and `lmr_api_key`) or
   **Gemini Terminal** (set `gemini_api_key`) on the **Configuration** tab,
   and start it

The image is built locally on your Home Assistant host during install, which
takes a few minutes.

See [lmr-terminal/DOCS.md](lmr-terminal/DOCS.md) and
[gemini-terminal/DOCS.md](gemini-terminal/DOCS.md) for all options.

## Credits

Based on [heytcass/home-assistant-addons](https://github.com/heytcass/home-assistant-addons)
(MIT). The terminal agents are OpenCode (LMR) and Gemini CLI (Gemini).

## License

MIT, see [LICENSE](LICENSE).

# Gemini Terminal for Home Assistant

A Home Assistant add-on that puts a web terminal in your sidebar, running
Google's [Gemini CLI](https://github.com/google-gemini/gemini-cli) agent. Ask
things like "why did my automation stop firing?" and let it read your config,
logs and entity states. It needs nothing but a Gemini API key, and is light
enough for a 2 GB Raspberry Pi.

## Installation

1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Open the three-dots menu → **Repositories**
3. Add `https://github.com/Dizzyobeah/home-assistant-addons`
4. Install **Gemini Terminal**, set `gemini_api_key` on the **Configuration**
   tab (create a key at [Google AI Studio](https://aistudio.google.com/apikey)),
   and start it

The image is built locally on your Home Assistant host during install, which
takes a few minutes.

See [gemini-terminal/DOCS.md](gemini-terminal/DOCS.md) for all options and
[gemini-terminal/CHANGELOG.md](gemini-terminal/CHANGELOG.md) for what changed
in each version.

## Making changes

Every change to the add-on needs both of these, in the same commit:

1. Bump `version` in `gemini-terminal/config.yaml`. Home Assistant only offers
   an update when the version changes.
2. Add an entry for that version at the top of `gemini-terminal/CHANGELOG.md`.
   Home Assistant shows it in the update dialog.

## Credits

Based on [heytcass/home-assistant-addons](https://github.com/heytcass/home-assistant-addons)
(MIT).

## License

MIT, see [LICENSE](LICENSE).

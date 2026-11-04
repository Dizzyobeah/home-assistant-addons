# Changelog

## 0.2.1

- Fix: shell commands from the agent no longer crash the session (signal 11).
  Gemini CLI's interactive shell (node-pty) has no Alpine build, so it is
  turned off. Commands run without a pseudo-terminal, so interactive programs
  such as `vim` won't work inside a tool call.

## 0.2.0

- The agent is now Google's Gemini CLI instead of OpenCode. Idle memory drops
  from ~1.3 GB to ~360 MB, so the add-on runs on a 2 GB Raspberry Pi.
- ha-mcp is installed once and reused, instead of being pre-warmed in the
  background on every start.

## 0.1.0

- First release: a web terminal in the Home Assistant sidebar running OpenCode
  with Google Gemini as the LLM backend. Needs only `gemini_api_key`.

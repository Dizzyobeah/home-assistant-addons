#!/bin/bash

# LMR Terminal banner — compact, non-blocking header with version and tips.
# With --shell, drops into an interactive bash afterwards (shell mode).
# Runs inside ttyd/tmux (user-visible) — plain bash, no bashio.

BLUE='\033[38;2;122;162;247m'
WHITE='\033[1;37m'
DIM='\033[2m'
NC='\033[0m'

version=$(cat /opt/scripts/addon-version 2>/dev/null || echo "unknown")

echo ""
echo -e "  ${BLUE}LMR Terminal${NC}  ${DIM}v${version} · Home Assistant add-on${NC}"
echo ""
echo -e "  ${WHITE}opencode${NC}          start the OpenCode agent  ${DIM}(-c continue last session)${NC}"
echo -e "  ${WHITE}persist-install${NC}   install apk/pip packages that survive restarts"
echo -e "  ${WHITE}ha-context${NC}        refresh the Home Assistant context file"
echo ""
echo -e "  ${DIM}Copy: hold Shift and drag · Paste: Ctrl+Shift+V${NC}"
echo ""

if [ "$1" = "--shell" ]; then
    exec bash
fi

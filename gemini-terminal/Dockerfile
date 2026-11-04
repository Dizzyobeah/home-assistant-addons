ARG BUILD_FROM
FROM ${BUILD_FROM}

# All runtime packages are baked into the image so startup never depends on
# the network
RUN apk add --no-cache \
    bash \
    curl \
    git \
    jq \
    nano \
    nodejs \
    npm \
    py3-aiohttp \
    py3-beautifulsoup4 \
    py3-pip \
    py3-requests \
    py3-yaml \
    python3 \
    tmux \
    tree \
    ttyd \
    vim \
    wget \
    yq

# uv from PyPI, pinned: Alpine 3.21's apk uv (0.5.x) cannot install managed
# musl CPython builds, which ha-mcp >= 4.x needs (it requires Python 3.13;
# Alpine 3.21 ships 3.12).
RUN pip3 install --no-cache-dir --break-system-packages uv==0.11.28

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Gemini CLI from npm. Pinned: gemini-settings.sh targets this version's
# settings schema; bump deliberately.
ARG GEMINI_CLI_VERSION=0.64.0
RUN npm install -g --no-fund --no-audit "@google/gemini-cli@${GEMINI_CLI_VERSION}" \
    && npm cache clean --force

WORKDIR /config

COPY run.sh /run.sh
COPY scripts/ /opt/scripts/
RUN chmod +x /run.sh /opt/scripts/*.sh

# ttyd's page with paste.js appended (served via --index). The page is
# compiled into the ttyd binary, so fetch it from a throwaway instance.
RUN mkdir -p /opt/ttyd \
    && { ttyd -p 7999 true >/dev/null 2>&1 & echo $! > /tmp/ttyd.pid; } \
    && for i in 1 2 3 4 5 6 7 8 9 10; do \
        curl -fsS --compressed -o /opt/ttyd/index.html http://127.0.0.1:7999/ && break; sleep 1; \
    done \
    && kill "$(cat /tmp/ttyd.pid)" && rm /tmp/ttyd.pid \
    && grep -q '</html>' /opt/ttyd/index.html \
    && { printf '<script>'; cat /opt/scripts/paste.js; printf '</script>\n'; } >> /opt/ttyd/index.html

CMD ["/run.sh"]

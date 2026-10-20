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

CMD ["/run.sh"]

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

# OpenCode, as the native musl binary straight from the npm registry (curl+tar
# instead of npm, so aarch64 cross-builds under QEMU don't need Node). x86_64
# uses the baseline build, which runs on CPUs without AVX (e.g. Proxmox kvm64).
# Pinned: opencode-config.sh targets this version's config schema; bump deliberately.
ARG OPENCODE_VERSION=1.19.3
RUN case "$(apk --print-arch)" in \
        x86_64)  pkg="opencode-linux-x64-baseline-musl" ;; \
        aarch64) pkg="opencode-linux-arm64-musl" ;; \
        *) echo "Unsupported architecture: $(apk --print-arch)" >&2; exit 1 ;; \
    esac \
    && version="$(curl -fsSL "https://registry.npmjs.org/${pkg}/${OPENCODE_VERSION}" | jq -r .version)" \
    && curl -fsSL "https://registry.npmjs.org/${pkg}/-/${pkg}-${version}.tgz" \
        | tar -xz -C /tmp package/bin/opencode \
    && install -m 0755 /tmp/package/bin/opencode /usr/local/bin/opencode \
    && rm -rf /tmp/package

WORKDIR /config

COPY run.sh /run.sh
COPY scripts/ /opt/scripts/
RUN chmod +x /run.sh /opt/scripts/*.sh

CMD ["/run.sh"]

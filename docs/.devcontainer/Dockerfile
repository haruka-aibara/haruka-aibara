FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install essential utility packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    # list installing packages
    unzip \
    zip \
    gzip \
    tar \
    curl \
    wget \
    htop \
    tree \
    jq \
    ca-certificates \
    # cleanup
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Python tools
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends \
#     python3-pip pipx \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Ansible
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends \
#     ansible ansible-lint \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm (supplementing the feature)
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends npm \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# ======================================================================
# uv - Python package and project manager
# ======================================================================
# Install uv for default user(vscode)
# Note: Direct curl installation doesn't work in this context
# Must use "su vscode" to execute as the vscode user
RUN su vscode -c "curl -LsSf https://astral.sh/uv/install.sh | sh"

# Make uv available in PATH
ENV PATH=/home/vscode/.local/bin:$PATH



# Add required libraries for Anaconda (optional)
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends \
#     libpci3 libgl1-mesa-glx libegl1-mesa libxrandr2 libxss1 \
#     libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 libsm6 \
#     libxext6 libxrender-dev libx11-xcb-dev libglu1-mesa-dev \
#     libxkbcommon-dev libxkbcommon-x11-dev libxcb-xinerama0 \
#     libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
#     libxcb-render-util0 libxcb-xkb1 \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /home/vscode/logs

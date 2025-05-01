FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install my favorite common tools
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends \
#     unzip jq zip gzip tar htop tree ca-certificates curl wget \
#     && apt-get clean -y && rm -rf /var/lib/apt/lists/*

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

# Install curl for downloading uv
RUN apt-get update && apt-get install -y curl

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Make uv available in PATH
ENV PATH=/home/vscode/.local/bin:$PATH

# ENV PATH=$HOME/.local/bin:$PATH
# RUN bash -c "source $HOME/.local/bin/env"

# Make uv available in PATH
# ENV PATH="/root/.cargo/bin:${PATH}"

# Verify installation
# RUN uv --version

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

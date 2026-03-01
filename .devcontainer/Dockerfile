FROM node:20-bookworm

# System dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    zsh \
    fzf \
    jq \
    iptables \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install oh-my-zsh for developer
USER $USERNAME
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Claude Code globally
USER root
RUN npm install -g @anthropic-ai/claude-code

# Install PAUL framework
RUN npx paul-framework --yes 2>/dev/null || true

# Install CARL
RUN npx carl-core --yes 2>/dev/null || true

# Copy firewall init script
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

USER $USERNAME
WORKDIR /workspace

# Set zsh as default shell
ENV SHELL=/usr/bin/zsh

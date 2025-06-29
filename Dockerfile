FROM ubuntu:22.04

ARG PYTHON_VERSION=3.12

# Set DEBIAN_FRONTEND to noninteractive for unattended installations
ENV DEBIAN_FRONTEND=noninteractive

# Install software-properties-common, curl, dirmngr, gnupg, and ca-certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    dirmngr \
    gnupg \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Add GitHub CLI repository key and repository
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    rm -rf /var/lib/apt/lists/*

# Manually add the deadsnakes PPA key(s) and repository definition
RUN mkdir -p /etc/apt/keyrings && \
    chmod 0755 /etc/apt/keyrings && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776 BA6932366A755776 && \
    gpg --export F23C5A6CF475977595C89F51BA6932366A755776 > /etc/apt/trusted.gpg.d/deadsnakes-primary.gpg && \
    gpg --export BA6932366A755776 > /etc/apt/trusted.gpg.d/deadsnakes-secondary.gpg && \
    echo "deb http://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/deadsnakes.list && \
    apt-get update && \
    rm -rf /var/lib/apt/lists/*

# Install general development tools and libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    vim \
    gh \
    libsm6 \
    libxext6 \
    libxrender-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.12 and its venv/dev packages from the PPA
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv && \
    rm -rf /var/lib/apt/lists/*

# Update alternatives to ensure python3 points to 3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1

# Install pip for the newly installed Python 3.12 and upgrade pip
RUN python${PYTHON_VERSION} -m ensurepip --upgrade && \
    python${PYTHON_VERSION} -m pip install --upgrade pip

# --- NEW INSTALLATION STEPS FOR TRANSFORMERS AND PYTORCH ---
# Install PyTorch with CUDA support (for GPU)
# The URL for PyTorch wheels needs to match your CUDA version on the L40.
# RunPod typically manages CUDA, so you often just need the correct wheel.
# For Ubuntu 22.04 with a modern GPU, this is a common command:
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    # Install the transformers library with PyTorch support
    pip install "transformers[torch]" && \
    # Install huggingface_hub if not pulled as a dependency of transformers[torch]
    pip install huggingface_hub

# Optional: Set a specific timezone if your application needs it
RUN echo "America/Los_Angeles" > /etc/timezone && \
    rm -f /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Temporary CMD for interactive access
CMD ["sleep", "infinity"]

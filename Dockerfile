# Use an official NVIDIA CUDA base image
FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

ARG PYTHON_VERSION=3.12

# Set DEBIAN_FRONTEND to noninteractive for unattended installations
ENV DEBIAN_FRONTEND=noninteractive

# Update apt cache and install basic necessities, INCLUDING CURL
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    vim \
    nano \
    # Removed git, wget, build-essential, gh as NVIDIA base has most or needs explicit install
    # Removed libsm6, libxext6, libxrender-dev as they might not be needed for CLI-only or come with NV image
    && rm -rf /var/lib/apt/lists/*

# Add GitHub CLI repository key and repository (now curl will be present)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && \
    rm -rf /var/lib/apt/lists/*

# Manually add the deadsnakes PPA key and repository definition
RUN mkdir -p /etc/apt/keyrings && \
    chmod 0755 /etc/apt/keyrings && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776 BA6932363755776 && \
    gpg --export F23C5A6CF475977595C89F51BA6932366A755776 > /etc/apt/trusted.gpg.d/deadsnakes-primary.gpg && \
    gpg --export BA6932366A755776 > /etc/apt/trusted.gpg.d/deadsnakes-secondary.gpg && \
    echo "deb http://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" | tee /etc/apt/sources.list.d/deadsnakes.list && \
    apt-get update && \
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

# Final aggressive installation for PyTorch and Transformers
RUN python3 -m pip cache purge && \
    python3 -m pip install --no-cache-dir --force-reinstall \
    torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --extra-index-url https://download.pytorch.org/whl/cu124 && \
    python3 -m pip install --no-cache-dir \
    transformers huggingface_hub

# Optional: Set a specific timezone if your application needs it
RUN echo "America/Los_Angeles" > /etc/timezone && \
    rm -f /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Temporary CMD for interactive access
CMD ["sleep", "infinity"]

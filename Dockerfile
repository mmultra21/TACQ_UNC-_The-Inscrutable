# Use an official NVIDIA CUDA base image
# This image comes with CUDA Toolkit, cuDNN, and nvcc pre-installed and configured.
# We'll use a 'devel' tag for development tools (like nvcc).
# Choose a CUDA version compatible with your PyTorch (e.g., cu12.1 or cu12.4).
# Your torch version is 2.5.1+cu124, so cuda:12.4.0-devel-ubuntu22.04 is ideal.
FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

ARG PYTHON_VERSION=3.12

# Set DEBIAN_FRONTEND to noninteractive for unattended installations
ENV DEBIAN_FRONTEND=noninteractive

# Update apt cache and install basic necessities, but a lot less now!
# The NVIDIA image already has build-essential, git, wget, curl.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    vim \
    nano \
    libsm6 \
    libxext6 \
    libxrender-dev \
    # The NVIDIA image should already have gpg, dirmngr, ca-certificates, gh (check if gh is needed)
    # If gh is still needed and not in base, add: gh
    && rm -rf /var/lib/apt/lists/*

# The NVIDIA image usually comes with Python, but let's re-ensure our 3.12 from deadsnakes
# This part is still needed to get Python 3.12 from the PPA.
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

# --- PYTORCH & TRANSFORMERS (SIMPLIFIED!) ---
# PyTorch is installed to match the CUDA Toolkit provided by the base image.
# We no longer need to manually manage specific CUDA versions or --index-url.
# The `torch` version `2.5.1` is compatible with CUDA 12.4.
# Use --extra-index-url https://download.pytorch.org/whl/cu124 to get the specific 12.4 build of torch
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

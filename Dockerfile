# Use an NVIDIA CUDA base image. Choose a CUDA version that is relatively recent
# and compatible with a PyTorch build that supports Python 3.12.
# You might need to check PyTorch's official installation guides for the exact wheel.
# Example: For CUDA 12.1 and Ubuntu 22.04
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHON_VERSION=3.12.2
ENV PIP_NO_CACHE_DIR=1

# Install common dependencies and Python 3.12.2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    software-properties-common \
    git \
    wget \
    curl \
    vim \
    libsm6 \
    libxext6 \
    libxrender-dev \
    # Install Python 3.12.2 from source or deadsnakes PPA if available for Ubuntu 22.04
    # This is a common way to get specific Python versions
    python${PYTHON_VERSION%.*}-venv \
    python${PYTHON_VERSION%.*}-dev \
    # Add deadsnakes PPA for newer Python versions if needed
    # apt-add-repository ppa:deadsnakes/ppa && \
    # apt-get update && \
    # apt-get install -y python3.12 python3.12-dev python3.12-venv && \
    # Update alternatives to ensure python3 points to 3.12
    # update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
# Install pip for Python 3.12
RUN apt-get install -y python3-pip && \
    pip install --upgrade pip

# Install PyTorch with CUDA support
# IMPORTANT: Check PyTorch's official website (pytorch.org/get-started/locally/) for
# the correct installation command and wheel for your desired PyTorch version,
# CUDA version, and Python 3.12. This example uses a placeholder.
# As of current knowledge, PyTorch 2.3+ might have wheels for Python 3.12 and CUDA 12.1.
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install TACQ requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Create a working directory and copy your project files
WORKDIR /app
COPY . /app

# (Optional) Install RunPod specific tools for better integration (SSH, JupyterLab)
# You might find these in official RunPod Dockerfiles on their GitHub
RUN apt-get install -y nginx openssh-server && \
    pip install jupyterlab && \
    mkdir -p /run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config # For simpler root login

# Set default command to keep the container running
# You can override this when launching the pod on RunPod
CMD ["sleep", "infinity"]

# Expose ports if you plan to run a web service (e.g., JupyterLab)
EXPOSE 8888 22
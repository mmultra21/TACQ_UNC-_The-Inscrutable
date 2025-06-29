# Start with a base image (e.g., Ubuntu 22.04)
# Make sure to choose a base image that is appropriate for your needs.
FROM ubuntu:22.04

# Set a build argument for the Python version (optional, but good practice)
ARG PYTHON_VERSION=3.12

# Install common dependencies and prepare for Python 3.12
# Use a single RUN instruction for apt-get update and apt-add-repository
# This is crucial for apt-get to see the new packages
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
    libxrender-dev && \
    # Add deadsnakes PPA for newer Python versions
    apt-add-repository -y ppa:deadsnakes/ppa && \
    apt-get update

# Install Python 3.12 and its venv/dev packages
# This should be a separate RUN instruction after the PPA is added and apt-get updated
RUN apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv

# Update alternatives to ensure python3 points to 3.12 (optional, but good for consistency)
# This assumes you want python3 to symlink to python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1

# Install pip for the newly installed Python 3.12 and upgrade pip
# This should be another separate RUN instruction
RUN python${PYTHON_VERSION} -m ensurepip --upgrade && \
    python${PYTHON_VERSION} -m pip install --upgrade pip

# You can now add other commands, e.g., for copying your application code
# COPY . /app
# WORKDIR /app
# RUN pip install -r requirements.txt
# CMD ["python3", "your_script.py"]

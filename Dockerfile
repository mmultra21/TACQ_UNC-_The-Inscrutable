FROM ubuntu:22.04

ARG PYTHON_VERSION=3.12

# Install software-properties-common, curl, dirmngr, and gnupg
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    curl \
    dirmngr \
    gnupg

# Manually add the deadsnakes PPA key and repository definition
# This is a more robust way to handle PPA keys in Dockerfiles
RUN curl -fsSL https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu/dists/jammy/InRelease.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/deadsnakes.gpg && \
    echo "deb http://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/deadsnakes.list && \
    apt-get update

# Install general development tools and libraries
RUN apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    vim \
    libsm6 \
    libxext6 \
    libxrender-dev

# Install Python 3.12 and its venv/dev packages from the PPA
RUN apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv

# Update alternatives to ensure python3 points to 3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1

# Install pip for the newly installed Python 3.12 and upgrade pip
RUN python${PYTHON_VERSION} -m ensurepip --upgrade && \
    python${PYTHON_VERSION} -m pip install --upgrade pip

# Your application specific commands go here
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD ["python3", "your_script.py"]

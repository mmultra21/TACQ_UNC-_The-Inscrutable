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
    ca-certificates

# Manually add the deadsnakes PPA key and repository definition
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776 && \
    gpg --export F23C5A6CF475997595C89F51BA6932366A755776 > /etc/apt/trusted.gpg.d/deadsnakes.gpg && \
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

# Optional: Set a specific timezone if your application needs it
RUN echo "America/Los_Angeles" > /etc/timezone && \
    rm -f /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Removed the application-specific lines that were causing the error
COPY . /app  <-- COMMENT OUT OR REMOVE FOR NOW
WORKDIR /app <-- COMMENT OUT OR REMOVE FOR NOW
RUN pip install -r requirements.txt <-- COMMENT OUT OR REMOVE FOR NOW

# This is the crucial change for interactive access:
# CMD ["/bin/bash"] # This is usually good, but if still issues, use sleep infinity
CMD ["sleep", "infinity"] # <-- Use this to guarantee the container stays running for the web terminal

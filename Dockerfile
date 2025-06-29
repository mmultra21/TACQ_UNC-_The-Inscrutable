FROM ubuntu:22.04

ARG PYTHON_VERSION=3.12

# Install software-properties-common first, as it provides apt-add-repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common

# Now, add the deadsnakes PPA and update apt again
RUN apt-add-repository -y ppa:deadsnakes/ppa && \
    apt-get update

# Install general development tools and libraries
RUN apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
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

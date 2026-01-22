# SPDX-License-Identifier: Apache-2.0
#
# Dockerfile for YOBIIQ KiBi SDK Build Environment
# Based on nRF Connect SDK v3.2.1
#

FROM ubuntu:22.04

LABEL org.opencontainers.image.title="YOBIIQ KiBi SDK Builder"
LABEL org.opencontainers.image.description="Build environment for YOBIIQ KiBi SDK with nRF Connect SDK v3.2.1"
LABEL org.opencontainers.image.version="3.2.1"
LABEL org.opencontainers.image.vendor="YOBIIQ"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    cmake \
    ninja-build \
    gperf \
    ccache \
    dfu-util \
    device-tree-compiler \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-tk \
    python3-wheel \
    xz-utils \
    file \
    make \
    gcc \
    gcc-multilib \
    g++-multilib \
    libsdl2-dev \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workdir

# Install west
RUN pip3 install --no-cache-dir west

# Install Zephyr SDK
ARG ZEPHYR_SDK_VERSION=0.16.5
RUN wget -q https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz && \
    tar xf zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz && \
    rm zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-x86_64.tar.xz && \
    cd zephyr-sdk-${ZEPHYR_SDK_VERSION} && \
    ./setup.sh -t all -h -c && \
    cd /workdir

ENV ZEPHYR_SDK_INSTALL_DIR=/workdir/zephyr-sdk-${ZEPHYR_SDK_VERSION}

# Initialize west workspace for nRF Connect SDK
ARG NCS_VERSION=v3.2.1
RUN west init -m https://github.com/nrfconnect/sdk-nrf --mr ${NCS_VERSION} ncs && \
    cd ncs && \
    west update -o=--depth=1 -n && \
    west zephyr-export

# Install Python dependencies for nRF Connect SDK
RUN pip3 install --no-cache-dir -r /workdir/ncs/zephyr/scripts/requirements.txt && \
    pip3 install --no-cache-dir -r /workdir/ncs/nrf/scripts/requirements.txt && \
    pip3 install --no-cache-dir -r /workdir/ncs/bootloader/mcuboot/scripts/requirements.txt

# Set environment variables
ENV ZEPHYR_BASE=/workdir/ncs/zephyr
ENV NRF_BASE=/workdir/ncs/nrf

# Clean up to reduce image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /workdir/ncs -name "*.git" -type d -exec rm -rf {} + 2>/dev/null || true

# Set working directory for builds
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]

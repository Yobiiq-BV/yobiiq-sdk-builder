#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Verify that the YOBIIQ SDK Builder Docker image is properly configured
#

set -e

IMAGE_NAME="${1:-ghcr.io/yobiiq/yobiiq-sdk-builder:v3.2.1}"

echo "========================================="
echo "YOBIIQ SDK Builder Image Verification"
echo "========================================="
echo "Image: ${IMAGE_NAME}"
echo ""

echo "[1/8] Checking West tool..."
docker run --rm "${IMAGE_NAME}" west --version
echo "✓ West is installed"
echo ""

echo "[2/8] Checking CMake..."
docker run --rm "${IMAGE_NAME}" cmake --version | head -n1
echo "✓ CMake is installed"
echo ""

echo "[3/8] Checking Ninja..."
docker run --rm "${IMAGE_NAME}" ninja --version
echo "✓ Ninja is installed"
echo ""

echo "[4/8] Checking Python..."
docker run --rm "${IMAGE_NAME}" python3 --version
echo "✓ Python is installed"
echo ""

echo "[5/8] Checking ARM GCC toolchain..."
docker run --rm "${IMAGE_NAME}" arm-zephyr-eabi-gcc --version | head -n1
echo "✓ ARM GCC toolchain is installed"
echo ""

echo "[6/8] Checking environment variables..."
docker run --rm "${IMAGE_NAME}" /bin/bash -c '
  echo "ZEPHYR_BASE: ${ZEPHYR_BASE}"
  echo "ZEPHYR_SDK_INSTALL_DIR: ${ZEPHYR_SDK_INSTALL_DIR}"
  if [ -z "${ZEPHYR_BASE}" ]; then
    echo "ERROR: ZEPHYR_BASE not set"
    exit 1
  fi
  if [ -z "${ZEPHYR_SDK_INSTALL_DIR}" ]; then
    echo "ERROR: ZEPHYR_SDK_INSTALL_DIR not set"
    exit 1
  fi
'
echo "✓ Environment variables are set"
echo ""

echo "[7/8] Checking nRF Connect SDK installation..."
docker run --rm "${IMAGE_NAME}" /bin/bash -c '
  if [ ! -d "${ZEPHYR_BASE}" ]; then
    echo "ERROR: Zephyr directory not found"
    exit 1
  fi
  echo "Zephyr directory: ${ZEPHYR_BASE}"
  if [ ! -d "/workdir/nrf" ]; then
    echo "ERROR: nRF directory not found"
    exit 1
  fi
  echo "nRF directory: /workdir/nrf"
  ls -la /workdir/nrf/ | head -n 10
'
echo "✓ nRF Connect SDK is installed"
echo ""

echo "[8/8] Building a test application (Zephyr hello_world)..."
docker run --rm "${IMAGE_NAME}" /bin/bash -c '
  cd /tmp
  cp -r ${ZEPHYR_BASE}/samples/hello_world .
  cd hello_world
  west build -b qemu_cortex_m3 --pristine -q
  if [ $? -eq 0 ]; then
    echo "Build successful!"
  else
    echo "ERROR: Build failed"
    exit 1
  fi
'
echo "✓ Test build completed successfully"
echo ""

echo "========================================="
echo "✓ All verification checks passed!"
echo "========================================="
echo ""
echo "The image is ready to use:"
echo "  docker pull ${IMAGE_NAME}"
echo "  docker run -it ${IMAGE_NAME}"

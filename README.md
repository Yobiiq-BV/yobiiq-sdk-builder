# YOBIIQ KiBi SDK Builder

Docker image providing a complete build environment for the YOBIIQ KiBi SDK, based on nRF Connect SDK v3.2.1.

## Overview

This repository contains the Dockerfile and build infrastructure for creating containerized build environments for YOBIIQ KiBi SDK development. The image includes:

- **nRF Connect SDK v3.2.1** - Nordic Semiconductor's SDK
- **Zephyr SDK 0.16.5** - ARM toolchain and build tools
- **West tool** - Meta-tool for managing Zephyr projects
- **Build tools** - CMake, Ninja, Python, and all required dependencies

## Quick Start

### Pull the Pre-built Image

```bash
docker pull ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1
```

### Run the Container

```bash
docker run -it --rm ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1
```

### Build Your Project

```bash
# Inside the container
cd /workdir
git clone https://github.com/YOUR-ORG/yobiiq-sdk.git
cd yobiiq-sdk
west build -b nrf52840dk_nrf52840 samples/hello_world
```

## Available Tags

| Tag | Description | Use Case |
|-----|-------------|----------|
| `v3.2.1` | Specific nRF SDK version | Production builds - recommended |
| `v3.2` | Major.minor version | Patch updates without breaking changes |
| `v3.2.1-2026-01` | Monthly rebuild | Security updates for specific version |
| `latest` | Latest build | Development only |
| `sha-abc123` | Git commit SHA | Reproducible builds |

## Using in CI/CD

### GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1
    steps:
      - uses: actions/checkout@v4
      - name: Build SDK
        run: |
          west build -b nrf52840dk_nrf52840 samples/hello_world
```

### GitLab CI

```yaml
build:
  image: ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1
  script:
    - west build -b nrf52840dk_nrf52840 samples/hello_world
```

## Local Development

### Using Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  builder:
    image: ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1
    volumes:
      - ./:/workspace
    working_dir: /workspace
    command: /bin/bash
```

Run:
```bash
docker-compose run --rm builder
```

### VS Code Dev Container

Create `.devcontainer/devcontainer.json`:

```json
{
  "name": "YOBIIQ SDK Development",
  "image": "ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1",
  "workspaceFolder": "/workspace",
  "mounts": [
    "source=${localWorkspaceFolder},target=/workspace,type=bind"
  ]
}
```

## Building Locally

### Prerequisites

- Docker installed and running
- At least 20 GB of free disk space
- Good internet connection (initial build downloads ~5 GB)

### Build Command

```bash
cd yobiiq-sdk-builder
chmod +x scripts/build-local.sh
./scripts/build-local.sh v3.2.1
```

Or manually:

```bash
docker build -t yobiiq-sdk-builder:v3.2.1 .
```

## Verification

Verify the image is properly configured:

```bash
chmod +x scripts/verify-image.sh
./scripts/verify-image.sh ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1
```

This will check:
- All required tools are installed
- Environment variables are set correctly
- nRF Connect SDK is accessible
- A sample application can be built

## What's Inside

### Installed Tools

- **West** - Zephyr meta-tool
- **CMake 3.x** - Build system generator
- **Ninja** - Fast build system
- **Python 3** - With all required packages
- **ARM GCC** - Cross-compilation toolchain
- **Git** - Version control
- **Device Tree Compiler** - For hardware descriptions

### Directory Structure

```
/workdir/                    # Main workspace
├── nrf/                     # nRF Connect SDK
│   ├── zephyr/             # Zephyr RTOS
│   ├── nrf/                # Nordic modules
│   └── ...                 # Other dependencies
/opt/zephyr-sdk-0.16.5/     # Zephyr SDK (toolchain)
```

### Environment Variables

- `ZEPHYR_BASE=/workdir/nrf/zephyr`
- `ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-0.16.5`
- `WORKSPACE_DIR=/workdir`

## Updating the Image

The image is automatically rebuilt:
- **Monthly** - On the 1st of each month (security updates)
- **On-demand** - Via GitHub Actions workflow dispatch
- **On changes** - When Dockerfile or VERSION.txt is updated

### Triggering a Manual Build

1. Go to the repository on GitHub
2. Navigate to Actions → "Build and Push Docker Image"
3. Click "Run workflow"
4. Select branch and optionally specify version

## Troubleshooting

### Image is too large

The image is typically 8-15 GB due to the full SDK. This is normal for embedded development environments.

### Build fails with "No space left on device"

Ensure you have at least 20 GB free disk space. Clean up Docker:
```bash
docker system prune -a
```

### Permission denied errors

The container runs as user `builder` (non-root). If you need root access:
```bash
docker run -it --user root ghcr.io/YOUR-ORG/yobiiq-sdk-builder:v3.2.1
```

### West update fails

The image includes a shallow clone of nRF SDK. For full history:
```bash
cd /workdir/nrf
west update --narrow=false
```

## Version History

| Version | nRF SDK | Zephyr SDK | Release Date |
|---------|---------|------------|--------------|
| v3.2.1  | v3.2.1  | 0.16.5     | 2026-01-22   |

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the Docker image builds successfully
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [YOBIIQ KiBi SDK](https://github.com/YOUR-ORG/yobiiq-sdk) - The SDK that uses this builder
- [nRF Connect SDK](https://github.com/nrfconnect/sdk-nrf) - Nordic's SDK
- [Zephyr Project](https://github.com/zephyrproject-rtos/zephyr) - Zephyr RTOS

## Support

For issues related to:
- **Docker image** - Open an issue in this repository
- **YOBIIQ SDK** - See the [SDK repository](https://github.com/YOUR-ORG/yobiiq-sdk)
- **nRF Connect SDK** - See [Nordic's documentation](https://developer.nordicsemi.com/)

## Changelog

### v3.2.1 (2026-01-22)
- Initial release
- nRF Connect SDK v3.2.1
- Zephyr SDK 0.16.5
- Ubuntu 22.04 base
- Monthly automated rebuilds
- Multi-tag support

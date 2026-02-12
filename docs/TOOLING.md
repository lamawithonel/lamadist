<!-- SPDX-License-Identifier: Apache-2.0 -->
# LamaDist Tooling Guide

This document describes the tools required for LamaDist development, how to set up your environment, and how to use the build system.

## Table of Contents

- [Overview](#overview)
- [Required Tools](#required-tools)
- [Development Environment Setup](#development-environment-setup)
- [Build System Usage](#build-system-usage)
- [Available Make Targets](#available-make-targets)
- [KAS Configuration](#kas-configuration)
- [Troubleshooting](#troubleshooting)

---

## Overview

LamaDist uses a containerized build approach to ensure reproducible builds across different development environments. The core tools are:

- **Docker**: Provides isolated, reproducible build environment
- **KAS**: Declarative Yocto/OE project setup and build tool
- **Make**: Orchestrates build commands and workflows
- **Python/Pipenv**: Manages Python dependencies
- **GitVersion**: Automatic semantic versioning

---

## Required Tools

### Host System Requirements

**Operating System**: Linux (Ubuntu 22.04 LTS recommended) or WSL2

**Minimum Hardware**:
- CPU: 4+ cores (8+ recommended)
- RAM: 8 GB minimum (16+ GB recommended)
- Disk: 100+ GB free space (SSD strongly recommended)
- Internet: For downloading sources and dependencies

### Core Tools

#### 1. Docker

**Required Version**: 20.10+ (with BuildKit support)

**Installation (Ubuntu/Debian)**:
```bash
# Install prerequisites
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add your user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

**Post-Installation**:
```bash
# Test Docker installation
docker run hello-world

# Enable Docker BuildKit (recommended)
echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
source ~/.bashrc
```

**Docker Configuration**:

For optimal build performance, configure Docker with sufficient resources:

```json
# ~/.docker/daemon.json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Restart Docker after changes:
```bash
sudo systemctl restart docker
```

#### 2. Python 3.12

**Required Version**: 3.12+ (3.12 recommended)

**Installation (Ubuntu 22.04)**:
```bash
# Install Python 3.12 from deadsnakes PPA
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.12 python3.12-venv python3.12-dev

# Verify installation
python3.12 --version
```

**Set Python 3.12 as default (optional)**:
```bash
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
```

#### 3. Git

**Required Version**: 2.25+

**Installation**:
```bash
sudo apt-get install -y git

# Configure Git (replace with your information)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### 4. Make

**Required Version**: Any recent version

**Installation**:
```bash
sudo apt-get install -y build-essential
```

### Optional Tools

#### GitVersion

**Purpose**: Automatic semantic versioning from Git history

**Installation**:
```bash
# GitVersion runs in Docker, no local installation needed
# The Makefile uses gittools/gitversion Docker image
```

**Verify**:
```bash
make version
```

#### Development Tools

For enhanced development experience:

```bash
# Code editors
sudo snap install code --classic  # VS Code

# Useful utilities
sudo apt-get install -y \
  vim \
  tmux \
  htop \
  tree \
  jq
```

---

## Development Environment Setup

### Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/lamawithonel/lamadist.git
   cd lamadist
   ```

2. **Set Up Python Virtual Environment**
   ```bash
   # Create virtual environment
   python3.12 -m venv .venv
   
   # Activate virtual environment
   source .venv/bin/activate
   
   # Verify Python version
   python --version  # Should show 3.12.x
   ```

3. **Install Development Dependencies**
   ```bash
   # Install Pipenv and other dev tools
   make dev-tools-locked
   ```

4. **Build the Container**
   ```bash
   # Build the kas build container
   make container
   ```

5. **Verify Setup**
   ```bash
   # Check that everything is working
   make dump BSP=x86_64
   ```

### Detailed Setup

#### Python Dependency Management

LamaDist uses Pipenv for Python dependency management with the following workflow:

```
Pipfile → Pipfile.lock → requirements files → Container
```

**Pipfile**: High-level dependency specifications
- Development and runtime dependencies
- Version constraints

**Pipfile.lock**: Locked dependency versions
- Generated from Pipfile
- Ensures reproducible installs

**requirements files**:
- `requirements-dev.txt`: Local development tools
- `container/requirements.txt`: Container Python packages

**Update Dependencies**:
```bash
# Update all lockfiles
make lockfiles

# Rebuild container with new dependencies
make container
```

#### Environment Variables

LamaDist uses environment variables for build configuration:

**.kas.env**: Environment variables passed to KAS container
- See `.kas.env` file for available variables
- Contains Docker/CI environment passthrough

**.kas.env.local**: Local overrides (not committed to git)
```bash
# Create local environment overrides
cat > .kas.env.local << 'EOF'
# Example: Set download directory
DL_DIR=/path/to/shared/downloads

# Example: Set shared state mirror
SSTATE_MIRRORS=file://.* http://my-sstate-server/PATH;downloadfilename=PATH

# Example: Limit CPU usage
BB_NUMBER_THREADS=4
PARALLEL_MAKE=-j 4
EOF
```

#### Build Cache Configuration

**Shared State Cache**: Cache of built packages
```bash
# Default location: .cache/sstate/
# Override with environment variable
export HOST_SSTATE_DIR=/path/to/sstate
```

**Download Directory**: Source tarballs
```bash
# Set in .kas.env.local
DL_DIR=/path/to/downloads
```

---

## Build System Usage

### Basic Build Commands

#### Build for Default BSP (x86_64)
```bash
make build
```

#### Build for Specific BSP
```bash
# Available BSPs: x86_64, orin-nx, rk1, soquartz
make build BSP=orin-nx
```

#### CI Build (with force checkout and update)
```bash
make ci-build
```

### Build Workflow

1. **First Build** (clean workspace):
   ```bash
   # Build container
   make container
   
   # Initial build (will take 2-6 hours depending on hardware)
   make build BSP=x86_64
   ```

2. **Incremental Builds** (with sstate cache):
   ```bash
   # Subsequent builds are much faster
   make build BSP=x86_64
   ```

3. **Clean Build** (remove build artifacts):
   ```bash
   # Remove output artifacts only
   make clean-outputs
   
   # Full clean (with confirmation)
   make clean-build-all
   ```

### Build Output Locations

After a successful build:

```
build/
├── downloads/              # Source tarballs
├── tmp/
│   ├── deploy/
│   │   ├── images/        # Final images (WIC, qcow2, etc.)
│   │   ├── rpm/           # RPM packages
│   │   └── licenses/      # License manifests
│   └── work/              # Build work directories
├── buildhistory/          # Build history tracking
└── buildstats/            # Build statistics
```

**Image files**:
- `build/tmp/deploy/images/<machine>/`
  - `*.wic.zst`: Compressed disk image
  - `*.ext4`: Root filesystem
  - `*.qcow2`: QEMU virtual machine image
  - `*.manifest`: Package list
  - `*.rootfs.json`: SPDX SBOM

---

## Available Make Targets

### Build Targets

| Target | Description |
|--------|-------------|
| `make build [BSP=<bsp>]` | Build images for specified BSP (default: x86_64) |
| `make ci-build` | Build with CI settings (force checkout, update) |
| `make container` | Build the kas build container image |

**Examples**:
```bash
make build                    # Build x86_64
make build BSP=rk1           # Build for RK1
make ci-build                # CI-style build
make container               # Rebuild container
```

### Development Targets

| Target | Description |
|--------|-------------|
| `make kas-shell` or `make kash` | Interactive shell in KAS environment |
| `make container-shell` | Shell in container (without KAS) |
| `make dump` | Dump KAS configuration |
| `make kas-shell-command` | Run command in KAS shell (use KAS_SHELL_COMMAND=) |

**Examples**:
```bash
# Start interactive KAS shell
make kash BSP=x86_64

# Dump configuration to review
make dump BSP=x86_64

# Run specific bitbake command
make kas-shell-command KAS_SHELL_COMMAND="bitbake -e core-image-minimal"
```

**In KAS shell**:
```bash
# You're in a BitBake environment
bitbake core-image-minimal          # Build an image
bitbake -c cleansstate <recipe>     # Clean a recipe
bitbake -e <recipe>                 # Show recipe environment
bitbake-layers show-layers          # List layers
bitbake-layers show-recipes         # List recipes
```

### Python Targets

| Target | Description |
|--------|-------------|
| `make lockfiles` | Update Python lockfiles (Pipfile.lock, requirements.txt) |
| `make dev-tools-locked` | Install development tools at pinned versions |

**Examples**:
```bash
# Update dependencies
vim Pipfile                  # Edit dependencies
make lockfiles              # Generate new lockfiles
make container              # Rebuild container with new deps

# Install dev tools locally
make dev-tools-locked
```

### Cleanup Targets

| Target | Description |
|--------|-------------|
| `make clean-outputs` | Remove build output artifacts |
| `make clean-build-tmp` | Remove build/tmp directory |
| `make clean-build-all` | Remove entire build directory (with confirmation) |
| `make clean-sstate-cache` | Clean shared state cache (with confirmation) |
| `make clean-container` | Remove container image |
| `make clean-venv` | Remove Python virtual environment |
| `make clean-lockfiles` | Remove Python lockfiles |

**Examples**:
```bash
# Clean outputs only (keep sstate)
make clean-outputs

# Full clean (will prompt for confirmation)
make clean-build-all

# Clean everything including sstate
make clean-sstate-cache
make clean-build-all
```

### Utility Targets

| Target | Description |
|--------|-------------|
| `make version` | Display build version (via GitVersion) |
| `make help` | Show all available targets with descriptions |

**Examples**:
```bash
# Get version
make version

# Show help
make help
```

---

## KAS Configuration

### KAS Overview

KAS (Setup tool for bitbake based projects) provides declarative configuration for Yocto builds.

**Benefits**:
- Reproducible builds
- Version-controlled configuration
- Easy composition of features
- No manual setup of `bblayers.conf` or `local.conf`

### Configuration Structure

```
kas/
├── main.kas.yml              # Base configuration
├── bsp/                      # BSP-specific configs
│   ├── x86_64.kas.yml
│   ├── orin-nx.kas.yml
│   ├── rk1.kas.yml
│   └── soquartz.kas.yml
├── extras/                   # Optional features
│   └── debug.kas.yml
└── installer.kas.yml         # Installer image config
```

### KAS Configuration Composition

KAS configs can be layered using `:` separator:

```bash
# Base + BSP
kas build main.kas.yml:bsp/x86_64.kas.yml

# Base + BSP + Debug
kas build main.kas.yml:bsp/x86_64.kas.yml:extras/debug.kas.yml

# Via Make (automatically includes debug)
make build BSP=x86_64
```

### Key KAS Configuration Elements

#### main.kas.yml

- Defines repositories (layers)
- Sets distribution (`lamadist`)
- Configures shared `local_conf_header` settings
- Specifies default branch (`scarthgap`)

#### BSP configs (bsp/*.kas.yml)

- Set `machine` variable
- Add BSP-specific repositories
- Define build targets
- Add machine-specific `local_conf_header` settings

#### Extras (extras/*.kas.yml)

- Optional feature overlays
- Debug settings
- Development tools
- Testing configurations

### Customizing KAS Configuration

To add local customizations without modifying tracked files:

1. **Create local KAS config**:
   ```yaml
   # kas/local.kas.yml (add to .gitignore)
   header:
     version: 15
   
   local_conf_header:
     my_custom_config: |
       # Custom BitBake configuration
       BB_NUMBER_THREADS = "8"
       PARALLEL_MAKE = "-j 8"
   ```

2. **Use in builds**:
   ```bash
   make kas-shell KAS_CONFIG="$(KAS_CONFIG):kas/local.kas.yml"
   ```

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Docker permission denied

**Symptom**:
```
docker: Got permission denied while trying to connect to the Docker daemon socket
```

**Solution**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again, or:
newgrp docker

# Verify
docker ps
```

#### Issue: Out of disk space

**Symptom**:
```
ERROR: No space left on device
```

**Solution**:
```bash
# Check disk usage
df -h

# Clean old build artifacts
make clean-outputs

# Clean downloads (will re-download on next build)
make clean-downloads

# Clean sstate cache (will rebuild on next build)
make clean-sstate-cache

# Prune Docker images
docker system prune -a
```

#### Issue: Build fails with hash mismatch

**Symptom**:
```
ERROR: Checksum mismatch!
```

**Solution**:
```bash
# Clear downloads and sstate
rm -rf build/downloads/<failing-package>*
rm -rf .cache/sstate/*<failing-package>*

# Retry build
make build
```

#### Issue: Python virtual environment issues

**Symptom**:
```
ImportError: No module named 'pipenv'
```

**Solution**:
```bash
# Remove and recreate virtual environment
make clean-venv
python3.12 -m venv .venv
source .venv/bin/activate
make dev-tools-locked
```

#### Issue: Container build fails

**Symptom**:
```
ERROR: failed to solve: failed to fetch...
```

**Solution**:
```bash
# Check Docker BuildKit is enabled
export DOCKER_BUILDKIT=1

# Clear Docker build cache
docker builder prune -a

# Rebuild container
make container
```

#### Issue: KAS cannot find layer

**Symptom**:
```
ERROR: Layer 'meta-xxx' is not in the collection
```

**Solution**:
```bash
# Update kas configuration to fetch all layers
make ci-build

# Or manually in kas shell
make kash
bitbake-layers show-layers  # Verify all layers present
```

### Performance Optimization

#### Speed Up Builds

1. **Use SSD**: Store build directory on SSD
2. **Increase parallelism**:
   ```bash
   # In .kas.env.local
   BB_NUMBER_THREADS=<cpu_cores>
   PARALLEL_MAKE=-j <cpu_cores * 1.5>
   ```
3. **Use shared sstate cache**: Point to network sstate mirror
4. **Use shared download directory**: Reuse downloads across workspaces
5. **Enable Icecream** (distributed compilation):
   ```bash
   # In .kas.env.local
   ICECC_DISABLED=0
   ```

#### Reduce Disk Usage

1. **Clean old builds regularly**: `make clean-outputs`
2. **Limit sstate cache size**: Use `sstate-cache-management` script
3. **Remove build history**: `make clean-build-history`
4. **Share downloads**: Use `DL_DIR` on separate partition

### Getting More Information

#### Enable verbose output

```bash
# Verbose make output
make build BSP=x86_64 VERBOSE=1

# KAS debug output (already enabled in Makefile)
# See KAS_BUILD_OPTS := --log-level debug
```

#### Check BitBake logs

```bash
# Main BitBake log
less build/tmp/log/cooker/<machine>/<timestamp>.log

# Task logs
less build/tmp/work/<arch>/<recipe>/<version>/temp/log.do_<task>.<pid>
```

#### Debug in KAS shell

```bash
# Enter KAS shell
make kash BSP=x86_64

# Run BitBake with debugging
bitbake -D core-image-minimal

# Show dependencies
bitbake -g core-image-minimal
```

---

## Additional Resources

### Documentation
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [KAS Documentation](https://kas.readthedocs.io/)
- [BitBake User Manual](https://docs.yoctoproject.org/bitbake/)

### Community
- [Yocto Project Mailing Lists](https://lists.yoctoproject.org/)
- [Yocto Project Discord](https://discord.gg/yocto)

### Tools
- [Docker Documentation](https://docs.docker.com/)
- [Pipenv Documentation](https://pipenv.pypa.io/)
- [GitVersion Documentation](https://gitversion.net/)

---

**Last Updated:** 2024  
**Document Version:** 1.0

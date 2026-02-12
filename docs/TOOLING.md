<!-- SPDX-License-Identifier: Apache-2.0 -->
# LamaDist Tooling Guide

This document describes the tools required for LamaDist development, how to set up your environment, and how to use the build system.

## Table of Contents

- [Overview](#overview)
- [Required Tools](#required-tools)
- [Development Environment Setup](#development-environment-setup)
- [Task Runner](#task-runner)
- [Build System Usage](#build-system-usage)
- [KAS Configuration](#kas-configuration)
- [Build Output Locations](#build-output-locations)
- [Troubleshooting](#troubleshooting)
- [Performance Optimization](#performance-optimization)

---

## Overview

LamaDist uses modern tooling to ensure reproducible builds across different development environments:

- **`mise`**: Polyglot tool version manager and task runner — single entry point for managing tool versions AND running project tasks
- **Docker**: Provides isolated, reproducible build environment for Yocto/KAS
- **KAS**: Declarative Yocto/OE project setup and build tool (runs inside Docker)
- **GitVersion**: Automatic semantic versioning from Git history

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

#### 1. mise

**Purpose**: Polyglot tool version manager and task runner (replaces Make, pyenv, nvm, rbenv, etc.)

`mise` is the single entry point for:
- Managing tool versions (Python, Node.js, etc.)
- Running project tasks (build, test, container, etc.)
- Ensuring consistent development environments

**Installation**:

```bash
# Quick install (recommended)
curl https://mise.run | sh

# Or via package manager (Ubuntu/Debian)
sudo install -dm 755 /etc/apt/keyrings
wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor | sudo tee /etc/apt/keyrings/mise-archive-keyring.gpg 1> /dev/null
echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg arch=amd64] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
sudo apt update
sudo apt install -y mise

# Or via Homebrew (macOS/Linux)
brew install mise

# Or via cargo
cargo install mise
```

**Shell Integration** (recommended for automatic activation):

```bash
# For bash
echo 'eval "$(mise activate bash)"' >> ~/.bashrc

# For zsh
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# For fish
echo 'mise activate fish | source' >> ~/.config/fish/config.fish
```

**Verify Installation**:
```bash
mise --version
```

**Documentation**: https://mise.jdx.dev/

#### 2. Docker

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

#### 3. Git

**Required Version**: 2.25+

**Installation**:
```bash
sudo apt-get install -y git

# Configure Git (replace with your information)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Optional Tools

#### GitVersion

**Purpose**: Automatic semantic versioning from Git history

**Installation**:
```bash
# GitVersion runs in Docker, no local installation needed
# The project uses gittools/gitversion Docker image
```

**Verify**:
```bash
mise run version
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

2. **Install mise** (if not already installed)
   ```bash
   curl https://mise.run | sh
   ```

3. **Install Tool Versions**
   ```bash
   # Install all tool versions defined in .mise.toml (when available)
   # Note: .mise.toml will be created in a future PR
   mise install
   ```

4. **Run Tasks**
   ```bash
   # List available tasks (when mise tasks are configured)
   mise tasks
   
   # For now, use make targets:
   # Build the container
   make container
   
   # Build image (this will take 2-6 hours on first build)
   make build
   ```

### mise Configuration

The project will use a `.mise.toml` file (in the repository root) to define:
- Tool versions to install (Python, etc.)
- Project tasks to run
- Environment variables

**Note**: The `.mise.toml` file and mise task definitions will be created in a future PR. This documentation describes the planned mise-based workflow. Until then, `make` targets remain the primary way to run project tasks.

### Environment Variables

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

### Build Cache Configuration

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

## Task Runner

`mise` will replace Make as the project's task runner. Tasks will be defined in `.mise.toml` at the project root.

**Current Status**: Task definitions are being migrated from `Makefile` to `mise`. Until the `.mise.toml` file is created in a future PR, continue using `make` commands. This section documents the planned mise-based workflow.

### Running Tasks (Planned)

```bash
# List all available tasks
mise tasks

# Run a task
mise run <task>

# Or use the shorter alias
mise r <task>

# Examples
mise run build           # Build for default BSP
mise run container       # Build container image
mise run kash           # Interactive KAS shell
mise run version        # Show version
```

### Common Tasks (Planned)

| Task | Description |
|------|-------------|
| `mise run build` | Build images for specified BSP (default: x86_64) |
| `mise run ci-build` | Build with CI settings (force checkout, update) |
| `mise run container` | Build the kas build container image |
| `mise run kash` | Interactive shell in KAS environment |
| `mise run dump` | Dump KAS configuration |
| `mise run version` | Display build version (via GitVersion) |

**Examples (Planned)**:
```bash
# Build for default BSP (x86_64)
mise run build

# Build for specific BSP
mise run build BSP=rk1

# Enter interactive KAS shell
mise run kash BSP=x86_64

# Show version
mise run version
```

**Current Workflow**: Use equivalent `make` targets until mise migration is complete:
```bash
make build              # Build for default BSP
make build BSP=rk1     # Build for specific BSP
make kash BSP=x86_64   # Interactive KAS shell
make version           # Show version
```

---

## Build System Usage

### Basic Build Commands

**Note**: The examples below show the planned `mise run` commands. Until mise tasks are implemented, use the equivalent `make` commands (e.g., `make build` instead of `mise run build`).

#### Build for Default BSP (x86_64)
```bash
# Planned: mise run build
# Current:
make build
```

#### Build for Specific BSP
```bash
# Available BSPs: x86_64, orin-nx, rk1, soquartz
# Planned: mise run build BSP=orin-nx
# Current:
make build BSP=orin-nx
```

#### CI Build (with force checkout and update)
```bash
# Planned: mise run ci-build
# Current:
make ci-build
```

### Build Workflow

1. **First Build** (clean workspace):
   ```bash
   # Build container (current: use make)
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

### Development Workflow

**Interactive KAS Shell**:
```bash
# Start interactive KAS shell (current: use make)
make kash BSP=x86_64

# You're now in a BitBake environment
bitbake core-image-minimal          # Build an image
bitbake -c cleansstate <recipe>     # Clean a recipe
bitbake -e <recipe>                 # Show recipe environment
bitbake-layers show-layers          # List layers
bitbake-layers show-recipes         # List recipes
```

**Dump Configuration**:
```bash
# Dump KAS configuration to review
make dump BSP=x86_64
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

# Via mise (automatically includes debug)
mise run build BSP=x86_64
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
   # Current: use make
   make kash KAS_CONFIG="$(KAS_CONFIG):kas/local.kas.yml"
   ```

---

## Build Output Locations

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

# Clean old build artifacts (current: use make)
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

# Retry build (current: use make)
make build
```

#### Issue: mise not found

**Symptom**:
```
bash: mise: command not found
```

**Solution**:
```bash
# Install mise
curl https://mise.run | sh

# Add shell integration
echo 'eval "$(mise activate bash)"' >> ~/.bashrc
source ~/.bashrc

# Or add to PATH manually
export PATH="$HOME/.local/bin:$PATH"
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

# Rebuild container (current: use make)
make container
```

#### Issue: KAS cannot find layer

**Symptom**:
```
ERROR: Layer 'meta-xxx' is not in the collection
```

**Solution**:
```bash
# Update kas configuration to fetch all layers (current: use make)
make ci-build

# Or manually in kas shell
make kash
bitbake-layers show-layers  # Verify all layers present
```

---

## Performance Optimization

### Speed Up Builds

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

### Reduce Disk Usage

1. **Clean old builds regularly**: `make clean-outputs`
2. **Limit sstate cache size**: Use `sstate-cache-management` script
3. **Remove build history**: `make clean-build-history`
4. **Share downloads**: Use `DL_DIR` on separate partition

### Getting More Information

#### Enable verbose output

```bash
# Verbose make output (current)
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
# Enter KAS shell (current: use make)
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
- [mise Documentation](https://mise.jdx.dev/)

### Community
- [Yocto Project Mailing Lists](https://lists.yoctoproject.org/)
- [Yocto Project Discord](https://discord.gg/yocto)

### Tools
- [Docker Documentation](https://docs.docker.com/)
- [mise Documentation](https://mise.jdx.dev/)
- [GitVersion Documentation](https://gitversion.net/)

---

**Last Updated:** 2026  
**Document Version:** 2.0

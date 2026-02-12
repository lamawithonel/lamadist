<!-- SPDX-License-Identifier: Apache-2.0 -->
# LamaDist Development Plan

This document outlines the phased development plan for the LamaDist project, a Yocto/OE distribution for homelab devices.

## Overview

LamaDist is designed to provide a secure, maintainable, and feature-rich Linux distribution for homelab hardware, including:
- x86_64 Intel-based systems
- ARM-based Single Board Computers (Orin NX, RK1, SOQuartz)

The development is organized into phases, with each phase building upon the previous to create a comprehensive distribution solution.

---

## Phase 0: Architecture Documentation + Tooling Baseline

**Status:** In Progress  
**Goal:** Establish project documentation, architecture baseline, and development standards.

### Steps

#### 0.1 Core Documentation
- [x] Create master development plan (`docs/PLAN.md`)
- [x] Create architecture documentation (`docs/ARCHITECTURE.md`)
- [x] Create contribution guidelines (`docs/CONTRIBUTING.md`)
- [x] Create tooling baseline documentation (`docs/TOOLING.md`)
- [x] Update README with documentation links and quick start

**Acceptance Criteria:**
- All documentation files exist in the `docs/` directory
- Documentation includes SPDX license headers
- README provides clear entry point to the project
- Documentation is well-structured with clear Markdown formatting

#### 0.2 Development Standards
- [ ] Define code review process and standards
- [ ] Establish commit message conventions
- [ ] Define branch naming strategy
- [ ] Create PR templates

**Acceptance Criteria:**
- Contribution guidelines document all development standards
- Standards are consistent with Yocto/OE best practices
- Clear examples provided for common scenarios

#### 0.3 Tooling Setup
- [ ] Document required tools and versions
- [ ] Create developer environment setup guide
- [ ] Document Make target usage
- [ ] Add troubleshooting section for common setup issues

**Acceptance Criteria:**
- New developers can set up environment from documentation
- All required tools are listed with version requirements
- Common issues have documented solutions

---

## Phase 1: Core Distribution Foundation

**Status:** Not Started  
**Goal:** Establish the foundational Yocto distribution configuration and layer structure.

### Steps

#### 1.1 Distribution Configuration
- [ ] Review and refine `meta-lamadist/conf/distro/lamadist.conf`
- [ ] Define distro feature set (security, containers, etc.)
- [ ] Configure package management (RPM with mandatory signing)
- [ ] Set up init system (systemd)
- [ ] Define optimization and build flags
- [ ] Establish systemd-first tool preference policy

**Acceptance Criteria:**
- Distro configuration is complete and well-documented
- All distro features have clear rationale
- Configuration follows Yocto best practices
- systemd tools are preferred over alternatives (systemd-timesyncd, systemd-networkd, etc.)
- RPM package format configured with signing requirements

#### 1.2 Layer Structure
- [ ] Organize `meta-lamadist` layer structure
- [ ] Define layer dependencies clearly
- [ ] Create layer documentation (README)
- [ ] Ensure layer compatibility with Yocto LTS releases

**Acceptance Criteria:**
- Layer structure follows OpenEmbedded standards
- Layer README documents purpose and usage
- Layer passes yocto-check-layer validation

#### 1.3 Machine Configurations
- [ ] Review and enhance machine configs for supported hardware
  - [ ] x86_64 Intel systems
  - [ ] Orin NX
  - [ ] RK1
  - [ ] SOQuartz
- [ ] Define bootloader configurations per machine
- [ ] Configure kernel selections per machine
- [ ] Set machine-specific features (TPM, UEFI, etc.)

**Acceptance Criteria:**
- Each supported machine has complete configuration
- Machine configs are modular and maintainable
- Hardware-specific features are properly enabled

#### 1.4 KAS Configuration Refinement
- [ ] Review and optimize KAS configurations
- [ ] Organize kas/bsp/ configurations
- [ ] Create kas/extras/ configurations for optional features
- [ ] Document KAS configuration layering approach

**Acceptance Criteria:**
- KAS configs are clean and well-organized
- BSP configs are minimal and focused
- Extras can be easily combined with base configs

---

## Phase 2: Package & Recipe Development

**Status:** Not Started  
**Goal:** Develop custom recipes, package groups, and image definitions.

### Steps

#### 2.1 Custom Recipe Development
- [ ] Create custom recipes for homelab-specific software
- [ ] Develop bbappends for upstream recipe customization
- [ ] Ensure recipes follow Yocto recipe style guidelines
- [ ] Add recipe documentation and comments
- [ ] Configure RPM package signing for all recipes

**Acceptance Criteria:**
- Custom recipes build successfully
- Recipes include license information
- Recipes follow naming conventions
- Recipe functionality is documented
- All packages are signed with GPG signatures

#### 2.2 Package Groups
- [ ] Define core package group (base system)
- [ ] Create homelab package group (common services)
- [ ] Create development package group (debugging tools)
- [ ] Create security package group (hardening tools)

**Acceptance Criteria:**
- Package groups are logical and maintainable
- Dependencies are clearly defined
- Groups can be composed for different use cases

#### 2.3 Image Definitions
- [ ] Create minimal base image recipe
- [ ] Create full-featured homelab image recipe
- [ ] Create development/debug image recipe
- [ ] Define image features and customizations
- [ ] Configure zstd compression (level 11) for image artifacts

**Acceptance Criteria:**
- Images build successfully for all targets
- Images are appropriately sized
- Image manifests and licenses are generated
- Images include proper documentation
- Compressed image artifacts use zstd level 11

#### 2.4 Recipe Testing
- [ ] Set up recipe testing framework
- [ ] Create tests for custom recipes
- [ ] Validate package installations
- [ ] Test image boot and functionality

**Acceptance Criteria:**
- All custom recipes have basic tests
- Images can be tested in QEMU
- Test results are documented

---

## Phase 3: Build Infrastructure & CI/CD

**Status:** Not Started  
**Goal:** Automate builds, implement testing pipelines, and manage artifacts.

### Steps

#### 3.1 Continuous Integration Setup
- [ ] Define GitHub Actions workflows
- [ ] Set up automated builds for all BSPs
- [ ] Configure build matrix (machine x image)
- [ ] Implement build caching strategies

**Acceptance Criteria:**
- Builds run automatically on PR and merge
- Build logs are accessible and clear
- Build times are optimized with caching
- Failed builds provide clear error messages

#### 3.2 Automated Testing
- [ ] Implement image boot tests
- [ ] Set up QEMU-based testing for supported machines
- [ ] Create smoke tests for critical functionality
- [ ] Implement security scanning in CI

**Acceptance Criteria:**
- Images are tested automatically
- Test results are reported in CI
- Security vulnerabilities are detected
- Test coverage meets minimum requirements

#### 3.3 Artifact Management
- [ ] Configure artifact storage (releases, containers)
- [ ] Set up sstate cache (if private)
- [ ] Implement download mirror
- [ ] Create artifact retention policies
- [ ] Generate SPDX 3.0.1 SBOM for all builds
- [ ] Configure zstd compression (level 11) for build artifacts

**Acceptance Criteria:**
- Build artifacts are stored reliably
- Artifacts are accessible to users
- Storage costs are managed
- Old artifacts are cleaned up automatically
- SPDX 3.0.1 SBOM generated for all images and packages
- Compressed artifacts use zstd level 11

#### 3.4 Build Reproducibility
- [ ] Implement fully reproducible builds
- [ ] Document build environment requirements
- [ ] Pin external dependencies
- [ ] Create build provenance documentation
- [ ] Verify build reproducibility in CI

**Acceptance Criteria:**
- Builds are fully reproducible given same inputs
- Build environment is documented
- Dependency versions are tracked
- Reproducibility is verified in automated testing

#### 3.5 Package Signing Infrastructure
- [ ] Set up GPG signing keys for RPM packages
- [ ] Configure TPM-backed key storage (where available)
- [ ] Implement automated package signing in build pipeline
- [ ] Establish key rotation and management procedures
- [ ] Configure signature verification in package manager

**Acceptance Criteria:**
- All RPM packages are automatically signed during build
- Signing keys are securely managed
- TPM integration configured for hardware-backed signing
- Signature verification is enforced on target systems
- Key management procedures are documented

---

## Phase 4: Device Integration & Testing

**Status:** Not Started  
**Goal:** Integrate with target hardware, establish deployment workflows, and implement OTA updates.

### Steps

#### 4.1 Hardware Testing
- [ ] Test images on physical x86_64 hardware
- [ ] Test images on Orin NX hardware
- [ ] Test images on RK1 hardware
- [ ] Test images on SOQuartz hardware
- [ ] Document hardware-specific issues and workarounds

**Acceptance Criteria:**
- Images boot successfully on target hardware
- All major hardware features are functional
- Issues are documented with workarounds
- Hardware-specific configurations are validated

#### 4.2 Bootloader Integration
- [ ] Configure and test systemd-boot for x86_64 (fallback for non-UKI boot)
- [ ] Configure bootloaders for ARM targets
- [ ] Implement secure boot where applicable
- [ ] Configure Measured Boot with TPM PCR measurements
- [ ] Configure Trusted Boot with IMA/EVM integration
- [ ] Implement platform-specific boot integrity features
- [ ] Test boot failure recovery
- [ ] Configure kernel command line for host configuration (hostname, machine-id, network)
- [ ] Package boot artifacts into UKI (Unified Kernel Image) on supported systems
- [ ] Configure UEFI to boot UKI directly (bypass bootloader where supported)

**Acceptance Criteria:**
- Bootloaders are properly configured for systems requiring them
- UKI direct boot is configured on UEFI systems (x86_64)
- Secure boot works on supported hardware with signed binaries
- Measured Boot configured on TPM-enabled systems
- Trusted Boot integrated with IMA/EVM
- Full boot integrity protection enabled on platforms supporting it
- Boot process is documented
- Recovery mechanisms are in place
- Host configuration via kernel command line is functional
- UKI executable generated for UEFI systems (x86_64)

#### 4.3 Storage and Partitioning
- [ ] Implement WIC-based disk image generation
- [ ] Configure dm-verity for immutable rootfs integrity
- [ ] Set up LUKS encryption for persistent data partition in A/B layout
- [ ] Test partition resizing and management
- [ ] Verify rootfs immutability and write protection

**Acceptance Criteria:**
- Disk images are properly partitioned with A/B layout
- Integrity verification works with dm-verity
- LUKS encryption is functional for persistent data
- Storage is optimally configured
- Rootfs is immutable and read-only

#### 4.4 OTA Update System
- [ ] Integrate RAUC for OTA updates
- [ ] Configure update bundles and slots
- [ ] Implement update verification
- [ ] Test rollback mechanisms
- [ ] Create update documentation for users

**Acceptance Criteria:**
- OTA updates work reliably
- Rollback is automatic on failure
- Update process is documented
- Updates preserve user data

#### 4.5 Deployment Workflows
- [ ] Create USB installer images
- [ ] Document network-based installation
- [ ] Create first-boot configuration scripts
- [ ] Document backup and restore procedures

**Acceptance Criteria:**
- Multiple deployment methods available
- Installation is well-documented
- First-boot setup is smooth
- Backup/restore is reliable

---

## Phase 5: Release Management & Maintenance

**Status:** Not Started  
**Goal:** Establish versioning, release processes, and ongoing maintenance procedures.

### Steps

#### 5.1 Versioning Strategy
- [ ] Define semantic versioning approach
- [ ] Set up GitVersion or equivalent
- [ ] Configure version tagging workflow
- [ ] Document version numbering scheme

**Acceptance Criteria:**
- Version numbers are consistent
- Versions are automatically generated
- Versioning scheme is documented
- Tags are properly created

#### 5.2 Release Process
- [ ] Define release criteria and checklist
- [ ] Create release branch strategy
- [ ] Automate release artifact generation
- [ ] Generate release notes automatically
- [ ] Create release announcement templates

**Acceptance Criteria:**
- Release process is documented
- Releases are consistent and repeatable
- Release artifacts are complete
- Release notes are comprehensive

#### 5.3 Security Updates
- [ ] Set up CVE monitoring
- [ ] Define security update SLA
- [ ] Create security advisory process
- [ ] Implement expedited security releases

**Acceptance Criteria:**
- CVEs are monitored continuously
- Security updates are timely
- Security process is documented
- Users are notified of security issues

#### 5.4 Long-term Maintenance
- [ ] Define LTS and standard release tracks
- [ ] Create backport policy
- [ ] Establish deprecation process
- [ ] Document end-of-life procedures

**Acceptance Criteria:**
- Maintenance policy is clear
- LTS releases are supported long-term
- Deprecations are well-communicated
- EOL process is defined

#### 5.5 Community and Support
- [ ] Create issue templates
- [ ] Set up discussion forums or mailing list
- [ ] Define support channels
- [ ] Create FAQ and troubleshooting guides

**Acceptance Criteria:**
- Users can easily get help
- Common issues are documented
- Community can contribute
- Support expectations are clear

---

## Future Phases (TBD)

Additional phases may be defined as the project matures:

- **Phase 6:** Advanced Features (clustering, orchestration, advanced security)
- **Phase 7:** Ecosystem Integration (cloud services, monitoring, logging)
- **Phase 8:** Performance Optimization (profiling, tuning, benchmarking)

---

## Success Metrics

### Phase 0
- Complete, well-structured documentation in place
- Development standards documented and adopted

### Phase 1
- Successful builds for all target machines
- Clean layer structure passing validation

### Phase 2
- Custom images building successfully
- All package groups defined and functional

### Phase 3
- Automated CI/CD pipeline operational
- Build times under target thresholds

### Phase 4
- Images successfully deployed to all target hardware
- OTA updates working reliably

### Phase 5
- Regular releases published
- Security updates delivered promptly
- Community engagement established

---

## Notes

- This plan is a living document and will be updated as the project evolves
- Each phase should be completed before moving to the next, but some overlap is acceptable
- Phases may be adjusted based on priorities, resources, and community feedback
- Security and quality should never be compromised for speed

---

**Last Updated:** 2024  
**Document Owner:** LamaDist Project Maintainer

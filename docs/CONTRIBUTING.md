<!-- SPDX-License-Identifier: Apache-2.0 -->
# Contributing to LamaDist

Thank you for your interest in contributing to LamaDist! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Branch Naming Conventions](#branch-naming-conventions)
- [Commit Message Standards](#commit-message-standards)
- [Pull Request Process](#pull-request-process)
- [Code Review Expectations](#code-review-expectations)
- [Yocto/OE Best Practices](#yoctooe-best-practices)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

---

## Code of Conduct

This project follows a code of conduct that we expect all contributors to adhere to:

- **Be respectful**: Treat all contributors with respect and consideration
- **Be collaborative**: Work together and help each other
- **Be inclusive**: Welcome contributors of all backgrounds and skill levels
- **Be constructive**: Provide helpful feedback and be open to receiving it
- **Be patient**: Remember that everyone is learning and improving

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Development Environment**: Linux system (Ubuntu 22.04 recommended) or WSL2
2. **Docker**: For containerized builds
3. **Git**: Version control
4. **Python 3.12**: For development tools
5. **Basic Knowledge**: Familiarity with Yocto/OE, Linux, and Git

See [TOOLING.md](TOOLING.md) for detailed setup instructions.

### Setting Up Your Development Environment

1. **Fork the Repository**
   ```bash
   # Fork lamawithonel/lamadist on GitHub
   # Then clone your fork
   git clone https://github.com/YOUR_USERNAME/lamadist.git
   cd lamadist
   ```

2. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/lamawithonel/lamadist.git
   git fetch upstream
   ```

3. **Install Development Tools**
   ```bash
   # Create Python virtual environment
   python3 -m venv .venv
   source .venv/bin/activate
   
   # Install dependencies
   make dev-tools-locked
   ```

4. **Build the Container**
   ```bash
   make container
   ```

5. **Verify Setup**
   ```bash
   # Try building for default BSP (x86_64)
   make build
   ```

---

## Development Workflow

### 1. Create a Feature Branch

Always work on a feature branch, never directly on `main`:

```bash
# Update your local main branch
git checkout main
git pull upstream main

# Create and checkout a new feature branch
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

- Make focused, logical changes
- Follow Yocto/OE best practices (see below)
- Test your changes locally
- Update documentation if needed

### 3. Commit Your Changes

```bash
# Stage your changes
git add <files>

# Commit with a descriptive message
git commit -m "type: brief description

Detailed explanation if needed.

Fixes #123"
```

See [Commit Message Standards](#commit-message-standards) below.

### 4. Keep Your Branch Updated

```bash
# Fetch upstream changes
git fetch upstream

# Rebase your branch on upstream/main
git rebase upstream/main

# Or merge if rebasing is problematic
git merge upstream/main
```

### 5. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 6. Open a Pull Request

- Go to the GitHub repository
- Click "New Pull Request"
- Select your fork and branch
- Fill out the PR template with all required information
- Link any related issues

---

## Branch Naming Conventions

Use clear, descriptive branch names following this pattern:

```
<type>/<short-description>
```

### Types

- `feature/` - New features or enhancements
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Adding or updating tests
- `chore/` - Maintenance tasks, build changes
- `security/` - Security fixes or improvements

### Examples

```
feature/add-k3s-support
fix/systemd-boot-timeout
docs/update-architecture
refactor/kas-config-structure
test/add-image-boot-tests
chore/update-dependencies
security/patch-cve-2024-1234
```

### Branch Naming Guidelines

- Use lowercase letters
- Use hyphens to separate words (not underscores or spaces)
- Keep names concise but descriptive
- Include issue number if applicable: `fix/123-boot-failure`

---

## Commit Message Standards

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no functional change)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system or dependency changes
- `ci`: CI/CD changes
- `chore`: Other changes that don't modify src or test files
- `revert`: Revert a previous commit
- `security`: Security fix or improvement

### Scope (Optional)

Specify the area affected by the change:

- `kas`: KAS configuration changes
- `meta`: Meta-layer changes
- `distro`: Distribution configuration
- `machine`: Machine configuration
- `recipe`: Recipe changes
- `docker`: Container/Docker changes
- `docs`: Documentation

### Examples

Good commit messages:

```
feat(recipe): add custom systemd service for monitoring

Add a new systemd service that monitors system health and reports
metrics. The service runs every 5 minutes and logs to journald.

Closes #42

---

fix(kas): correct layer dependency order

The meta-security layer must come before meta-virtualization to
avoid conflicting package versions.

Fixes #156

---

docs(architecture): update security architecture section

Add detailed explanation of dm-verity integration and how it
interacts with the initramfs boot process.

---

security(distro): update kernel to address CVE-2024-1234

Backport security patches for CVE-2024-1234.

CVE: CVE-2024-1234
```

Bad commit messages:

```
❌ updated stuff
❌ fix
❌ WIP
❌ asdfasdf
❌ minor changes
```

### Commit Message Guidelines

- **First line**: 50 characters or less, imperative mood ("add" not "added" or "adds")
- **Body**: Wrap at 72 characters, explain what and why (not how)
- **Footer**: Reference issues, PRs, CVEs, or breaking changes
- **Sign-off**: Use `git commit -s` to sign off on commits (DCO)

---

## Pull Request Process

### Before Submitting

- [ ] Code follows Yocto/OE best practices
- [ ] All commits have clear, descriptive messages
- [ ] Branch is up to date with `upstream/main`
- [ ] Changes have been tested locally
- [ ] Documentation has been updated
- [ ] No sensitive information (keys, passwords) in commits

### PR Description Template

```markdown
## Description
Brief description of the changes in this PR.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Related Issues
Fixes #(issue number)
Related to #(issue number)

## Testing
Describe the testing you've done:
- [ ] Tested on x86_64
- [ ] Tested on ARM (specify platform)
- [ ] Built successfully
- [ ] Image boots and runs

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings or errors
- [ ] Any dependent changes have been merged and published
```

### PR Size Guidelines

- **Small PRs are preferred**: Easier to review, test, and merge
- **One logical change per PR**: Don't mix unrelated changes
- **Large changes**: Break into multiple PRs if possible
- **Justification**: If PR is large, explain why in description

### PR Labels

Maintainers will add labels to categorize PRs:

- `bug` - Bug fixes
- `enhancement` - New features
- `documentation` - Documentation changes
- `security` - Security-related
- `needs-review` - Awaiting review
- `work-in-progress` - Not ready for merge
- `blocked` - Blocked by another issue/PR

---

## Code Review Expectations

### For Authors

- **Respond promptly**: Address review comments in a timely manner
- **Be open to feedback**: Reviewers are trying to improve the code
- **Ask questions**: If you don't understand a comment, ask for clarification
- **Don't take it personally**: Reviews are about the code, not you
- **Push updates**: After addressing comments, push updates and respond

### For Reviewers

- **Be constructive**: Explain the "why" behind suggestions
- **Be specific**: Point to exact lines and provide examples
- **Be timely**: Review PRs within a reasonable time frame
- **Approve or request changes**: Make your intent clear
- **Test changes**: If possible, test the changes locally

### Review Criteria

Reviewers will check for:

- **Correctness**: Does the code do what it's supposed to?
- **Quality**: Is the code clean, readable, and maintainable?
- **Testing**: Are changes adequately tested?
- **Documentation**: Is documentation updated?
- **Best practices**: Does it follow Yocto/OE conventions?
- **Security**: Are there any security concerns?
- **Performance**: Any performance implications?

---

## Yocto/OE Best Practices

### Recipe Writing

1. **Use SPDX License Identifiers**
   ```bitbake
   # SPDX-License-Identifier: MIT
   ```

2. **Include Clear License Information**
   ```bitbake
   LICENSE = "MIT"
   LIC_FILES_CHKSUM = "file://LICENSE;md5=..."
   ```

3. **Use Appropriate Recipe Style**
   ```bitbake
   SUMMARY = "Brief one-line description"
   DESCRIPTION = "Longer, more detailed description of the package"
   HOMEPAGE = "https://project.homepage.com"
   SECTION = "devel"
   ```

4. **Proper Variable Ordering**
   - License information first
   - SRC_URI and checksums
   - Dependencies (DEPENDS, RDEPENDS)
   - Build configuration (inherit, EXTRA_OECONF, etc.)
   - Install tasks
   - Package configuration

5. **Use bbappends Appropriately**
   - Place in your layer, not upstream layers
   - Keep minimal and focused
   - Document why the append is needed

### KAS Configuration

1. **Keep configs modular**: Base configs + BSP overlays + feature overlays
2. **Document overrides**: Comment complex configurations
3. **Pin versions**: Specify branches/tags for reproducibility
4. **Use proper YAML syntax**: Valid YAML with clear structure

### Layer Management

1. **Layer dependencies**: Declare all dependencies in `layer.conf`
2. **Layer priority**: Set appropriate `BBFILE_PRIORITY`
3. **Layer compatibility**: Update `LAYERSERIES_COMPAT` for each release
4. **Layer README**: Maintain comprehensive layer documentation

---

## Testing Requirements

### Local Testing

Before submitting a PR, test your changes:

```bash
# Build for your target BSP
make build BSP=x86_64

# Test in QEMU (if applicable)
runqemu nographic

# Check for warnings/errors in build logs
```

### Build Testing

- Ensure clean builds from scratch
- Test with and without sstate cache
- Verify no new warnings introduced

### Image Testing

If you've modified images or core recipes:

- Boot test on target hardware (if available)
- Verify key functionality works
- Test upgrade path (if modifying update system)

### Documentation Testing

If you've modified documentation:

- Ensure Markdown is properly formatted
- Verify links work
- Check for typos/grammar issues

---

## Documentation

### When to Update Documentation

Update documentation when you:

- Add new features
- Change existing behavior
- Add new configuration options
- Fix bugs that weren't obvious
- Add new tools or dependencies

### Documentation Types

- **README.md**: Quick start and overview
- **docs/PLAN.md**: Development roadmap
- **docs/ARCHITECTURE.md**: System architecture
- **docs/TOOLING.md**: Tools and setup
- **docs/CONTRIBUTING.md**: This file
- **Recipe comments**: Inline documentation in recipes
- **Commit messages**: Detailed explanations

### Documentation Standards

- Use clear, concise language
- Include examples where helpful
- Keep formatting consistent
- Update table of contents when adding sections
- Include SPDX license headers

---

## Getting Help

If you need help:

- **Documentation**: Check docs/ directory first
- **Issues**: Search existing issues on GitHub
- **Discussions**: Start a discussion on GitHub Discussions
- **Maintainers**: Tag maintainers in issues/PRs for specific questions

---

## License

By contributing to LamaDist, you agree that your contributions will be licensed under the Apache License 2.0, consistent with the project's existing license.

All contributions must include the SPDX license identifier:
```
# SPDX-License-Identifier: Apache-2.0
```

---

## Recognition

Contributors will be recognized in:
- Git commit history
- Release notes
- Project documentation (if significant contribution)

Thank you for contributing to LamaDist!

---

**Last Updated:** 2024  
**Document Version:** 1.0

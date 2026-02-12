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
2. **mise**: Polyglot tool manager (https://mise.jdx.dev)
3. **podman** or Docker: Container runtime for builds
4. **Git**: Version control
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
   # Install mise-managed tools (Python, etc.)
   mise install
   ```

4. **Verify Setup**
   ```bash
   # Try building for default BSP (x86_64)
   mise run build --bsp x86_64
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
- Test your changes locally with `mise run build --bsp <bsp>`
- Update documentation if needed

### 3. Commit Your Changes

```bash
# Stage your changes
git add <files>

# Commit with a descriptive message including trailers
git commit -m "type(scope): brief description

Detailed explanation if needed.

Fixes: #123
See: https://relevant-url.com"
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
git push origin <type>/<your-feature-name>
```

### 6. Open a Pull Request

- Go to the GitHub repository
- Click "New Pull Request"
- Select your fork and branch
- Fill out the PR template with all required information
- Link any related issues

---

## Branch Naming Conventions

LamaDist uses **JIT Flow**, a hybrid branching strategy that combines the simplicity of feature-branch flow with the flexibility to maintain release branches only when needed.

### JIT Flow Overview

```
main (latest unstable)
  │
  ├── feature/add-k3s-support ──┐
  ├── fix/systemd-boot ─────────┼─→ (merged to main)
  ├── docs/update-architecture ─┘
  │
  ├── v1.0.0 (tag: first release)
  │
  ├── feature/breaking-change ───→ (introduces incompatibility)
  │   │
  │   └── release/1.0 (forked from commit before breaking change)
  │       │
  │       ├── v1.0.1 (tag: patch on release branch)
  │       └── v1.0.2 (tag: another patch)
  │
  ├── v2.0.0 (tag: new release with breaking change)
  │
  └── HEAD (latest unstable)
```

### Feature Branch Types

All feature branches use the pattern:
```
<type>/<short-description>
```

**Valid type prefixes** (any Conventional Commit type):
- `feature/` - New features or enhancements
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Adding or updating tests
- `chore/` - Maintenance tasks, build changes
- `security/` - Security fixes or improvements
- `ci/` - CI/CD changes
- `build/` - Build system changes
- `perf/` - Performance improvements
- `revert/` - Reverting previous changes
- `style/` - Code style/formatting changes

**Feature branches**:
- Branch off `main`
- Merge back to `main` via Pull Request
- Deleted after merge

### Release Branches

**Release branches** are created only when needed:
```
release/<major>[.<minor>][-codename]
```

**When to create a release branch**:
- A breaking change is about to be merged to `main`
- Fork from the commit **prior** to the breaking change
- Use format: `release/1.0` or `release/1.0-stable`

**Release branch behavior**:
- Receives important bug fixes and security patches (backported from `main`)
- Should NOT receive new features
- Always behind `main` in terms of features
- Tagged for patch releases (e.g., `v1.0.1`, `v1.0.2`)

### Tags and Releases

- **Tags on `main`**: Create new releases (e.g., `v1.0.0`, `v2.0.0`)
- **Tags on release branches**: Create patch releases (e.g., `v1.0.1`, `v1.0.2`)
- **Latest stable**: Latest tag on `main`
- **Latest unstable**: `HEAD` of `main`

### Branch Naming Guidelines

- Use lowercase letters
- Use hyphens to separate words (not underscores or spaces)
- Keep names concise but descriptive
- Include issue number if applicable: `fix/123-boot-failure`

### Examples

```
feature/add-k3s-support
fix/systemd-boot-timeout
docs/update-architecture
refactor/kas-config-structure
test/add-image-boot-tests
chore/update-dependencies
security/patch-cve-2024-1234
ci/add-github-actions
build/migrate-to-mise
perf/optimize-build-cache
```

---

## Commit Message Standards

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification with **strongly encouraged** scope usage and git trailers for metadata.

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

### Scope (Strongly Encouraged)

Specify the area affected by the change:

- `kas`: KAS configuration changes
- `meta`: Meta-layer changes
- `distro`: Distribution configuration
- `machine`: Machine configuration
- `recipe`: Recipe changes
- `container`: Container/Docker/Podman changes
- `docs`: Documentation
- `tooling`: Build tooling (mise, Makefile)
- `github`: GitHub templates, workflows

### Git Trailers

Git trailers provide structured metadata and should be placed in the footer, separated from the body by a blank line:

**Common trailers**:
- `Fixes: #<issue>` - Links to a GitHub issue this commit fixes (closes automatically)
- `Closes: #<issue>` - Alternative to Fixes for closing issues
- `See: <url>` - Reference to related documentation, PRs, or resources
- `Ticket: <ticket-id>` - Link to external tracking system (optional)
- `CVE: <cve-id>` - Reference to CVE being addressed
- `Signed-off-by: Name <email>` - Developer Certificate of Origin
- `Co-authored-by: Name <email>` - Credit for co-authors

**Trailer format rules**:
- Use `Trailer: value` format (colon-space separator)
- Place in footer, separated from body by blank line
- One trailer per line
- Do NOT use bare `Fixes #123` in body (use `Fixes: #123` trailer)

### Examples

Good commit messages with trailers:

```
feat(recipe): add custom systemd service for monitoring

Add a new systemd service that monitors system health and reports
metrics. The service runs every 5 minutes and logs to journald.

Closes: #42
See: https://systemd.io/JOURNAL_NATIVE_PROTOCOL/

---

fix(kas): correct layer dependency order

The meta-security layer must come before meta-virtualization to
avoid conflicting package versions.

Fixes: #156

---

docs(architecture): update security architecture section

Add detailed explanation of dm-verity integration and how it
interacts with the initramfs boot process.

See: https://www.kernel.org/doc/html/latest/admin-guide/device-mapper/verity.html

---

security(distro): update kernel to address CVE-2024-1234

Backport security patches for CVE-2024-1234 affecting the
network stack.

CVE: CVE-2024-1234
Fixes: #287
See: https://nvd.nist.gov/vuln/detail/CVE-2024-1234

---

build(tooling): migrate to mise task runner

Replace Make targets with mise tasks for improved developer
experience and shell autocompletion support.

See: https://mise.jdx.dev/
Ticket: PROJ-456
```

Bad commit messages:

```
❌ updated stuff
❌ fix
❌ WIP
❌ asdfasdf
❌ minor changes
❌ Fixed #123 (should use Fixes: #123 as trailer)
```

### Commit Message Guidelines

- **First line**: 50 characters or less, imperative mood ("add" not "added" or "adds")
- **Scope**: Strongly encouraged for all commits
- **Body**: Wrap at 72 characters, explain what and why (not how)
- **Footer**: Use git trailers for all metadata
- **Sign-off**: Use `git commit -s` to sign off on commits (DCO)

---

## Pull Request Process

### Before Submitting

- [ ] Code follows Yocto/OE best practices
- [ ] All commits have clear, descriptive messages with proper trailers
- [ ] Branch is up to date with `upstream/main`
- [ ] Changes have been tested locally
- [ ] Documentation has been updated
- [ ] No sensitive information (keys, passwords) in commits
- [ ] Commits follow Conventional Commits with scope (strongly encouraged) and git trailers

### PR Template

Pull requests should use the template in `.github/PULL_REQUEST_TEMPLATE.md` which includes:
- Description of changes
- Type of change (bug fix, feature, breaking change, etc.)
- Related issues (with proper `Fixes: #123` or `Closes: #123` format)
- Testing checklist
- General PR checklist

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
mise run build --bsp x86_64

# Interactive shell for debugging
mise run shell --bsp x86_64

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

**Last Updated:** 2026  
**Document Version:** 2.0

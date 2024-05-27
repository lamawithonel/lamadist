# SPDX-License-Identifier: Apache-2.0

BUILD_VERSION   ?= $(shell docker run --rm -v "$(PROJECT_DIR):/repo" gittools/gitversion /repo /showvariable FullSemVer)
PROJECT_DIR     := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
HOST_SSTATE_DIR ?= $(shell realpath $(abspath $(PROJECT_DIR)/.cache/sstate))

BSP ?= x86_64

KAS_WORK_DIR := /0
KAS_CONFIG 	 := $(KAS_WORK_DIR)/kas/main.kas.yml:$(KAS_WORK_DIR)/kas/bsp/$(BSP).kas.yml
KAS_DEBUG    := $(KAS_WORK_DIR)/kas/extras/debug.kas.yml

KAS_INSTALLER     := $(KAS_WORK_DIR)/kas/extras/installer.kas.yml
KAS_BUILD_OPTS    := --log-level debug
KAS_BUILD_OPTS_CI := --force-checkout --update

ifneq ("$(wildcard $(PROJECT_DIR)/.kas.env.local)","")
    KAS_ENV_LOCAL := --env-file $(PROJECT_DIR)/.kas.env.local
else
    KAS_ENV_LOCAL :=
endif
CONTAINER_IMAGE := lamawithonel/lamadist-builder:latest
SSTATE_DIR := /sstate
DOCKER_RUN := docker run --rm -it \
	--privileged \
	-v /dev:/dev \
	-v "$(HOST_SSTATE_DIR):$(SSTATE_DIR)" \
	-e "SSTATE_DIR=$(SSTATE_DIR)" \
	-v "$(PROJECT_DIR):$(KAS_WORK_DIR)" \
	-e "KAS_WORK_DIR=$(KAS_WORK_DIR)" \
	--env-file $(PROJECT_DIR)/.kas.env $(KAS_ENV_LOCAL)
DOCKER_RUN_KAS := $(DOCKER_RUN) $(CONTAINER_IMAGE)


########################################################################
# Python targets

PYTHON := $(abspath .venv/bin/python)

.PHONY: lockfiles
lockfiles: Pipfile.lock requirements-dev.txt container/requirements.txt  ## Update the lockfiles
.venv:
	python -m venv --upgrade-deps .venv
.venv/bin/pipenv: .venv
	$(PYTHON) -m pip install pipenv
Pipfile.lock: .venv/bin/pipenv
	$(PYTHON) -m pipenv lock --dev
container/requirements.txt: Pipfile.lock
	$(PYTHON) -m pipenv requirements --hash > $@

.PHONY: dev-tools-locked
dev-tools-locked: requirements-dev.txt  ## Install the development tools at their pinned versions
	$(PYTHON) -m pip install -r $<
requirements-dev.txt: Pipfile.lock
	$(PYTHON) -m pipenv requirements --hash --dev-only > $@


########################################################################
# Build targets

.cache/sstate:
	mkdir -p $@

.PHONY: container
container: dev-tools-locked container/requirements.txt  ## Build the kas build container
	DOCKER_BUILDKIT=1 docker build -t $(CONTAINER_IMAGE) container/

.PHONY: ci-build
ci-build: .cache/sstate  ## Build all outputs with settings for CI
	$(DOCKER_RUN_KAS) build $(KAS_BUILD_OPTS_CI) '$(KAS_CONFIG)'

.PHONY: build
build: .cache/sstate  ## Build the outputs
	$(DOCKER_RUN_KAS) $(KAS_BUILD_OPTS) build '$(KAS_CONFIG):$(KAS_DEBUG)'


########################################################################
# Debugging targets

.PHONY: dump
dump: .cache/sstate  ## Dump the kas build configuration
	$(DOCKER_RUN_KAS) dump '$(KAS_CONFIG):$(KAS_DEBUG)'

.PHONY: container-shell
container-shell: .cache/sstate  ## Start a shell inside the kas build container without running kas (for debugging)
	$(DOCKER_RUN) --entrypoint /bin/dumb-init $(CONTAINER_IMAGE) /bin/bash

.PHONY: kash
kash: kas-shell  ## Alias for kas-shell
.PHONY: kas-shell
kas-shell: .cache/sstate  ## Start a shell in the kas environment, inside the build container
	$(DOCKER_RUN_KAS) shell '$(KAS_CONFIG):$(KAS_DEBUG)'

.PHONY: kas-shell-command
kash-shell-command: .cache/sstate
	$(DOCKER_RUN_KAS) shell -c $(KAS_SHELL_COMMAND) '$(KAS_CONFIG):$(KAS_DEBUG)'


########################################################################
# Cleanup targets
#

.PHONY: clean-venv
clean-venv:
	rm -rf $(PROJECT_DIR)/.venv

.PHONY: clean-lockfiles
clean-lockfiles:
	rm -f $(PROJECT_DIR)/Pipfile.lock
	rm -f $(PROJECT_DIR)/requirements-dev.txt
	rm -f $(PROJECT_DIR)/container/requirements.txt

.PHONY: clean-container
clean-container: clean-lockfiles clean-venv  ## Remove the kas build container
	docker rmi $(CONTAINER_IMAGE)

.PHONY: clean-downloads
clean-downloads:
	rm -rf $(PROJECT_DIR)/build/downloads

.PHONY: clean-outputs
clean-outputs:  ## Remove build artifacts
	rm -rf $(PROJECT_DIR)/build/tmp/deploy

.PHONY: clean-build-history
clean-build-history:
	rm -rf $(PROJECT_DIR)/build/buildhistory

.PHONY: clean-build-stats
clean-build-stats:
	rm -rf $(PROJECT_DIR)/build/buildstats

.PHONY: clean-build-tmp
clean-build-tmp:
	rm -rf $(PROJECT_DIR)/build/tmp

.PHONY: clean-prompt
clean-prompt:
	@read -p 'Are you sure you want to remove the full build directory? [y/N] ' -n 1 -r; \
	echo; \
	if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
		exit 1; \
	fi

.PHONY: clean-build-all
clean-build-all: clean-prompt
	rm -rf $(PROJECT_DIR)/build/*

.PHONY: clean-sstate-cache
clean-sstate-cache: clean-prompt
	rm -rf $(HOST_SSTATE_DIR)/*


########################################################################
# Utility targets

.PHONY: version
version:  ## Print the build version
	@echo $(BUILD_VERSION)

.PHONY: help
help: ## Show this help message
	@echo -e '\033[1mUsage:\033[0m\n  make \033[34m<target> [BSP=<bsp>]\033[0m\n'
	@echo -e '\033[1mAvailable targets:\033[0m'
	@grep -E '^[[:alpha:]_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) \
		| grep -v '^help:' \
		| sort \
		| awk 'BEGIN { FS = ":.*?## "; };{ \
			printf "  \033[34m%-17s\033[0m ", $$1; \
			desc = $$2; \
			gsub(/[[:print:]]{40,48} /, "&\n                    ", desc); \
			sub(/^[[:blank:]]+/, "", desc); \
			printf "%s\n", desc; \
		}'
	@printf '  \033[34m%-17s\033[0m %s\n' 'help:' 'Show this help message'
	@echo -e '\n\033[1mAvailable BSPs:\033[0m'
	@for _bsp in $$(ls kas/bsp/*.kas.yml | sort); do \
		_bsp=$$(basename $$_bsp); \
		_bsp=$${_bsp%.kas.yml}; \
		printf '  \033[34m%-17s\033[0m\n' $$_bsp; \
	done

QGIS_BRANCH = release-3_26
DOCKER_TAG ?= latest
DOCKER_BASE = camptocamp/qgis-server
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
export DOCKER_BUILDKIT = 1

DOCKER_COMPOSE_TTY := $(shell [ ! -t 0 ] && echo -T)
BUILD_OPTIONS = build

.PHONY: help
help: ## Display this help message
	@echo "Usage: make <target>"
	@echo
	@echo "Available targets:"
	@grep --extended-regexp --no-filename '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "	%-20s%s\n", $$1, $$2}'

.PHONY: all
all: build acceptance ## Build and run acceptance tests

.PHONY: build-server
build-server: ## Build the server Docker image
	DOCKER_BUILDKIT=1 docker $(BUILD_OPTIONS) --target=runner-server --tag=$(DOCKER_BASE):$(DOCKER_TAG) --build-arg=QGIS_BRANCH=$(QGIS_BRANCH) .

.PHONY: build-desktop
build-desktop: ## Build the desktop Docker image
	DOCKER_BUILDKIT=1 docker $(BUILD_OPTIONS) --target=runner-desktop --tag=$(DOCKER_BASE):$(DOCKER_TAG)-desktop --build-arg=QGIS_BRANCH=$(QGIS_BRANCH) .

.PHONY: build-cache
build-cache:
	DOCKER_BUILDKIT=1 docker $(BUILD_OPTIONS) --target=cache --tag=qgis-cache --build-arg=QGIS_BRANCH=$(QGIS_BRANCH) .

.PHONY: build ## Build all the Docker images
build: build-server build-desktop

.PHONY: build-acceptance-config
build-acceptance-config:
	DOCKER_BUILDKIT=1 docker build --tag=$(DOCKER_BASE)-acceptance_config:$(DOCKER_TAG) acceptance_tests/config

.PHONY: build-acceptance
build-acceptance: build-acceptance-config
	DOCKER_BUILDKIT=1 docker build --tag=$(DOCKER_BASE)-acceptance:$(DOCKER_TAG) acceptance_tests

.PHONY: run
run: build-acceptance
	mkdir -p acceptance_tests/junitxml && touch acceptance_tests/junitxml/results.xml
	cd acceptance_tests; docker-compose up -d

.PHONY: acceptance
acceptance: run ## Run the acceptance tests
	cd acceptance_tests; docker-compose exec $(DOCKER_COMPOSE_TTY) run pytest -vv --color=yes --junitxml=/tmp/junitxml/results.xml
	cd acceptance_tests; docker-compose exec $(DOCKER_COMPOSE_TTY) qgis python3 -c 'import qgis'

.PHONY: run-client
run-client: ## Run the desktop application
	docker run --rm -ti -e DISPLAY=unix${DISPLAY} --volume=/tmp/.X11-unix:/tmp/.X11-unix --volume=${HOME}:${HOME} $(DOCKER_BASE):$(DOCKER_TAG)-desktop

clean:
	rm -rf acceptance_tests/junitxml/ server/build server/target

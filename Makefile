DOCKER_TAG ?= latest
DOCKER_BASE = camptocamp/qgis-server
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
GID = $(shell id -g)
UID = $(shell id -u)

#Get the IP address of the docker interface
DOCKER_HOST = $(shell ifconfig docker0 | head -n 2 | tail -n 1 | awk -F : '{print $$2}' | awk '{print $$1}')

#Get the docker version (must use the same version for acceptance tests)
DOCKER_VERSION_ACTUAL = $(shell docker version --format '{{.Server.Version}}')
ifeq ($(DOCKER_VERSION_ACTUAL),)
DOCKER_VERSION = 1.12.0
else
DOCKER_VERSION = $(DOCKER_VERSION_ACTUAL)
endif

#Get the docker-compose version (must use the same version for acceptance tests)
DOCKER_COMPOSE_VERSION_ACTUAL = $(shell docker-compose version --short)
ifeq ($(DOCKER_COMPOSE_VERSION_ACTUAL),)
DOCKER_COMPOSE_VERSION = 1.8.0
else
DOCKER_COMPOSE_VERSION = $(DOCKER_COMPOSE_VERSION_ACTUAL)
endif

.PHONY: all
all: build acceptance

src:
	git clone git://github.com/qgis/QGIS.git src && cd src && git checkout release-2_16

.PHONY: update-src
update-src: src
	cd src; git pull --rebase

.PHONY: build-builder
build-builder:
	docker build --tag $(DOCKER_BASE)-builder:$(DOCKER_TAG) builder

.PHONY: build-src
build-src: build-builder update-src
	mkdir -p server/build server/target
	docker run --rm -ti -e UID=$(UID) -e GID=$(GID) --volume $(ROOT)/src:/src --volume $(ROOT)/server/build:/build --volume $(ROOT)/server/target:/usr/local $(DOCKER_BASE)-builder:$(DOCKER_TAG)

.PHONY: build-server
build-server: build-src
	docker build --tag $(DOCKER_BASE):$(DOCKER_TAG) server

.PHONY: build
build: build-server

.PHONY: build-acceptance-config
build-acceptance-config:
	docker build --tag=$(DOCKER_BASE)-acceptance_config:$(DOCKER_TAG) acceptance_tests/config

.PHONY: build-acceptance
build-acceptance: build-acceptance-config
	@echo "Docker version: $(DOCKER_VERSION)"
	@echo "Docker-compose version: $(DOCKER_COMPOSE_VERSION)"
	docker build --build-arg DOCKER_VERSION="$(DOCKER_VERSION)" --build-arg DOCKER_COMPOSE_VERSION="$(DOCKER_COMPOSE_VERSION)" -t $(DOCKER_BASE)-acceptance:$(DOCKER_TAG) acceptance_tests

.PHONY: acceptance
acceptance: build-acceptance build
	docker run --rm -ti --add-host=host:${DOCKER_HOST} -e DOCKER_TAG=$(DOCKER_TAG) -e ACCEPTANCE_DIR=${ROOT}/acceptance -v /var/run/docker.sock:/var/run/docker.sock $(DOCKER_BASE)-acceptance:$(DOCKER_TAG)

.PHONY: acceptance-quick
acceptance-quick: build-acceptance
	docker run --rm -ti --add-host=host:${DOCKER_HOST} -e DOCKER_TAG=$(DOCKER_TAG) -e ACCEPTANCE_DIR=${ROOT}/acceptance -v /var/run/docker.sock:/var/run/docker.sock $(DOCKER_BASE)-acceptance:$(DOCKER_TAG)

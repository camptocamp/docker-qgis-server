QGIS_BRANCH = master
DOCKER_TAG ?= latest
DOCKER_BASE = camptocamp/qgis-server
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
GID = $(shell id -g)
UID = $(shell id -u)

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
	git clone git://github.com/qgis/QGIS.git src

.PHONY: update-src
update-src: src
	cd src && git checkout $(QGIS_BRANCH) && git pull --rebase && git log -n 1

.PHONY: build-builder
build-builder:
	docker build --tag $(DOCKER_BASE)-builder:$(DOCKER_TAG) builder

.PHONY: build-src
build-src: build-builder update-src
	mkdir -p server/build server/target
	docker run --rm -e UID=$(UID) -e GID=$(GID) --volume $(ROOT)/src:/src --volume $(ROOT)/server/build:/build --volume $(ROOT)/server/target:/usr/local --volume $(HOME)/.ccache:/home/builder/.ccache $(DOCKER_BASE)-builder:$(DOCKER_TAG)

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
	mkdir -p acceptance_tests/junitxml && touch acceptance_tests/junitxml/results.xml
	docker run --rm -e DOCKER_TAG=$(DOCKER_TAG) -v /var/run/docker.sock:/var/run/docker.sock -v $(ROOT)/acceptance_tests/junitxml:/tmp/junitxml $(DOCKER_BASE)-acceptance:$(DOCKER_TAG)

.PHONY: acceptance-quick
acceptance-quick: build-acceptance
	mkdir -p acceptance_tests/junitxml && touch acceptance_tests/junitxml/results.xml
	docker run --rm -e DOCKER_TAG=$(DOCKER_TAG) -v /var/run/docker.sock:/var/run/docker.sock -v $(ROOT)/acceptance_tests/junitxml:/tmp/junitxml $(DOCKER_BASE)-acceptance:$(DOCKER_TAG)

.PHONY: pull
pull:
	for image in `find -name Dockerfile | xargs grep --no-filename FROM | awk '{print $$2}'`; do docker pull $$image; done

.PHONY: run-client
run-client: build-server
	docker run --rm -ti -e DISPLAY=unix${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix -v ${HOME}:${HOME} $(DOCKER_BASE):$(DOCKER_TAG) /usr/local/bin/start-client.sh

clean:
	rm -rf acceptance_tests/junitxml/ server/build server/target

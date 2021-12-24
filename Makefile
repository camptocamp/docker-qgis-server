QGIS_BRANCH = fix-headers
GIT_REMOTE = https://github.com/sbrunner/QGIS

export DOCKER_TAG ?= latest
export DOCKER_BASE = camptocamp/qgis-server
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

DOCKER_COMPOSE_TTY := $(shell [ ! -t 0 ] && echo -T)
BUILD_OPTIONS = build

.PHONY: all
all: build acceptance

.PHONY: build-server
build-server:
	DOCKER_BUILDKIT=1 docker $(BUILD_OPTIONS) --target=runner-server --tag=$(DOCKER_BASE):$(DOCKER_TAG) \
	--build-arg=QGIS_BRANCH=$(QGIS_BRANCH) --build-arg=GIT_REMOTE=$(GIT_REMOTE) .

.PHONY: build-desktop
build-desktop:
	DOCKER_BUILDKIT=1 docker $(BUILD_OPTIONS) --target=runner-desktop --tag=$(DOCKER_BASE):$(DOCKER_TAG)-desktop \
	--build-arg=QGIS_BRANCH=$(QGIS_BRANCH) --build-arg=GIT_REMOTE=$(GIT_REMOTE) .

.PHONY: build-cache
build-cache:
	DOCKER_BUILDKIT=1 docker $(BUILD_OPTIONS) --target=cache --tag=qgis-cache \
	--build-arg=QGIS_BRANCH=$(QGIS_BRANCH) --build-arg=GIT_REMOTE=$(GIT_REMOTE) .

.PHONY: build
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
acceptance:
	cd acceptance_tests; docker-compose exec $(DOCKER_COMPOSE_TTY) run pytest -vv --color=yes --junitxml=/tmp/junitxml/results.xml

.PHONY: pull
pull:
	for image in `find -name Dockerfile | xargs grep --no-filename ^FROM |grep -v 'FROM runner'|grep -v 'FROM builder'| awk '{print $$2}'`; do docker pull $$image; done

.PHONY: run-client
run-client:
	docker run --rm -ti -e DISPLAY=unix${DISPLAY} --volume=/tmp/.X11-unix:/tmp/.X11-unix --volume=${HOME}:${HOME} $(DOCKER_BASE):$(DOCKER_TAG)-desktop

clean:
	rm -rf acceptance_tests/junitxml/ server/build server/target

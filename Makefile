QGIS_BRANCH = master
DOCKER_TAG ?= latest
DOCKER_BASE = camptocamp/qgis-server
ROOT = $(dir $(realpath $(firstword $(MAKEFILE_LIST))))


DOCKER_COMPOSE_TTY := $(shell [ ! -t 0 ] && echo -T)

.PHONY: all
all: build acceptance

.PHONY: build
build: build
	docker build --target=runner-server --tag=$(DOCKER_BASE):$(DOCKER_TAG) --build-arg=QGIS_BRANCH=$(QGIS_BRANCH) .
	docker build --target=runner-desktop --tag=$(DOCKER_BASE):$(DOCKER_TAG)-desktop --build-arg=QGIS_BRANCH=$(QGIS_BRANCH) .

.PHONY: build-acceptance-config
build-acceptance-config:
	docker build --tag=$(DOCKER_BASE)-acceptance_config:$(DOCKER_TAG) acceptance_tests/config

.PHONY: build-acceptance
build-acceptance: build-acceptance-config
	docker build --tag=$(DOCKER_BASE)-acceptance:$(DOCKER_TAG) acceptance_tests

.PHONY: run
run: build-acceptance build
	mkdir -p acceptance_tests/junitxml && touch acceptance_tests/junitxml/results.xml
	cd acceptance_tests; docker-compose up -d

.PHONY: acceptance
acceptance:
	cd acceptance_tests; docker-compose exec $(DOCKER_COMPOSE_TTY) run py.test -vv --color=yes --junitxml=/tmp/junitxml/results.xml

.PHONY: pull
pull:
	for image in `find -name Dockerfile | xargs grep --no-filename ^FROM |grep -v 'FROM runner'|grep -v 'FROM builder'| awk '{print $$2}'`; do docker pull $$image; done

.PHONY: run-client
run-client: build
	docker run --rm -ti -e DISPLAY=unix${DISPLAY} --volume=/tmp/.X11-unix:/tmp/.X11-unix --volume=${HOME}:${HOME} $(DOCKER_BASE):$(DOCKER_TAG)-desktop

clean:
	rm -rf acceptance_tests/junitxml/ server/build server/target

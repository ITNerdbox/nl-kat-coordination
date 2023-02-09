SHELL := bash
.ONESHELL:

# use HIDE to run commands invisibly, unless VERBOSE defined
HIDE:=$(if $(VERBOSE),,@)
UNAME := $(shell uname)

.PHONY: kat kat-stable rebuild update clean clone clone-stable migrate build itest debian-build-image ubuntu-build-image

# Export Docker buildkit options
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

SERVICES = nl-kat-rocky nl-kat-boefjes nl-kat-bytes nl-kat-octopoes nl-kat-mula nl-kat-keiko


kat: env-if-empty clean clone build up # This should give you a clean install

kat-stable: env-if-empty clean clone-stable build up # This should give you a clean install of a stable version

rebuild: clean build up

update: down pull build up

clean: down # This should clean up all persistent data
	-docker volume rm nl-kat-coordination_rocky-db-data nl-kat-coordination_bytes-db-data nl-kat-coordination_katalogus-db-data nl-kat-coordination_xtdb-data nl-kat-coordination_scheduler-db-data
	-docker-compose run --rm -u root bytes rm -rf bytes-data

export version

upgrade: fetch down # Upgrade to the latest release without losing persistent data. Usage: `make upgrade version=v1.5.0` (version is optional)
ifeq ($(version),)
	version=$(shell curl --silent  "https://api.github.com/repos/minvws/nl-kat-rocky/tags" | jq -r '.[].name' | grep -v "rc" | head -n 1)
endif
	make checkout branch=$(version)
	make build-all
	make up

reset: down
	-docker volume rm nl-kat-coordination_bytes-db-data nl-kat-coordination_katalogus-db-data nl-kat-coordination_xtdb-data nl-kat-coordination_scheduler-db-data
	-docker-compose run --rm -u root bytes rm -rf bytes-data
	make -C nl-kat-rocky almost-flush

up:
	docker-compose up -d --force-recreate

down:
	-docker-compose down

clone:
	for service in $(SERVICES); do
		git clone https://github.com/minvws/$$service.git;
	done

clone-stable:
	for service in $(SERVICES); do
		TAG=$(shell curl --silent  "https://api.github.com/repos/minvws/nl-kat-rocky/tags" | jq -r '.[].name' | grep -v "rc" | head -n 1);
		git clone --branch $$TAG https://github.com/minvws/$$service.git;
	done

fetch:
	for service in . $(SERVICES); do
		git -C $$service fetch;
	done

pull:
	for service in . $(SERVICES); do
		git -C $$service pull;
	done

env-if-empty:
ifeq ("$(wildcard .env)","")
	make env
endif

env:  # Create .env file from the env-dist with randomly generated credentials from vars annotated by "{%EXAMPLE_VAR}"
	$(HIDE) cp .env-dist .env
ifeq ($(UNAME), Darwin)  # Different sed on MacOS
	$(HIDE) grep -o "{%\([_A-Z]*\)}" .env-dist | sort -u | while read v; do sed -i '' "s/$$v/$$(openssl rand -hex 25)/g" .env; done
else
	$(HIDE) grep -o "{%\([_A-Z]*\)}" .env-dist | sort -u | while read v; do sed -i "s/$$v/$$(openssl rand -hex 25)/g" .env; done
endif

checkout: # Usage: `make checkout branch=develop`
	for service in . $(SERVICES); do
		git -C $$service checkout $(branch);
	done

pull-reset:
	for service in . $(SERVICES); do
		git -C $$service reset --hard HEAD;
		git -C $$service pull;
	done

build-all:  # Build should prepare all other services: migrate them, seed them, etc.
ifeq ($(UNAME), Darwin)
	docker-compose build --build-arg USER_UID="$$(id -u)"
else
	docker-compose build --build-arg USER_UID="$$(id -u)" --build-arg USER_GID="$$(id -g)"
endif

build: build-all
	make -C nl-kat-rocky build
	make -C nl-kat-boefjes build
	make -C nl-kat-bytes build

debian-build-image:
	docker build -t kat-debian-build-image packaging/debian

ubuntu-build-image:
	docker build -t kat-ubuntu-build-image packaging/ubuntu

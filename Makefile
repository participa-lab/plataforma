

SHELL=/bin/bash

export ENV_NAME = dev.env
export ENV_LOCATION = polis
export ENV_FILE = ${ENV_LOCATION}/${ENV_NAME}
export TAG = $(shell grep -e ^TAG ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,""); print $$2}')
export POLIS_GIT_BRANCH = $(shell grep -e ^POLIS_GIT_BRANCH ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,""); print $$2}')
export POLIS_GIT_SHA = $(shell grep -e ^POLIS_GIT_SHA ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,""); print $$2}')
export PARTICIPA_GIT_BRANCH = $(shell grep -e ^PARTICIPA_GIT_BRANCH ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,""); print $$2}')
export PARTICIPA_GIT_SHA = $(shell grep -e ^PARTICIPA_GIT_SHA ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,""); print $$2}')
export COMPOSE_FILE_ARGS = -f docker-compose.yml

init:
	git clone git@github.com:participa-lab/participa.git
	git clone git@github.com:participa-lab/polis.git

update-env:
	cp -R *.env polis/

use-git-branch: # Use sha if set, if not use branch
	@echo "Using git branch ${POLIS_GIT_BRANCH} and sha ${POLIS_GIT_SHA}"
	if [ -z "${POLIS_GIT_SHA}" ]; then \
		cd polis && git checkout ${POLIS_GIT_BRANCH} && git pull; \
	else \
		cd polis && git checkout ${POLIS_GIT_SHA} && git pull; \
	fi
	@echo "Using git branch ${PARTICIPA_GIT_BRANCH} and sha ${PARTICIPA_GIT_SHA}"
	if [ -z "${PARTICIPA_GIT_SHA}" ]; then \
		cd participa && git checkout ${PARTICIPA_GIT_BRANCH} && git pull; \
	else \
		cd participa && git checkout ${PARTICIPA_GIT_SHA} && git pull; \
	fi

PROD: ## Run in prod mode (e.g. `make PROD start`, etc.) using config in `prod.env`
	$(eval ENV_NAME = prod.env)
	$(eval ENV_FILE = ${ENV_LOCATION}/${ENV_NAME})
	$(eval TAG = $(shell grep -e ^TAG ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval POLIS_GIT_BRANCH = $(shell grep -e ^POLIS_GIT_BRANCH ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval POLIS_GIT_SHA = $(shell grep -e ^POLIS_GIT_SHA ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval PARTICIPA_GIT_BRANCH = $(shell grep -e ^PARTICIPA_GIT_BRANCH ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval PARTICIPA_GIT_SHA = $(shell grep -e ^PARTICIPA_GIT_SHA ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval COMPOSE_FILE_ARGS = -f docker-compose.yml)

TEST: ## Run in test mode (e.g. `make TEST e2e-run`, etc.) using config in `test.env`
	$(eval ENV_NAME = test.env)
	$(eval ENV_FILE = ${ENV_LOCATION}/${ENV_NAME})
	$(eval TAG = $(shell grep -e ^TAG ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval POLIS_GIT_BRANCH = $(shell grep -e ^POLIS_GIT_BRANCH ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval POLIS_GIT_SHA = $(shell grep -e ^POLIS_GIT_SHA ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval PARTICIPA_GIT_BRANCH = $(shell grep -e ^PARTICIPA_GIT_BRANCH ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval PARTICIPA_GIT_SHA = $(shell grep -e ^PARTICIPA_GIT_SHA ${ENV_NAME} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval COMPOSE_FILE_ARGS = -f docker-compose.yml)

echo_vars: update-env use-git-branch
	@echo ENV_FILE=${ENV_FILE}
	@echo TAG=${TAG}

pull: echo_vars ## Pull most recent Docker container builds (nightlies)
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} pull

start: echo_vars ## Start all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up

start-sm: echo_vars ## Start all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up server nginx-proxy participa --force-recreate

start-math: echo_vars ## Start all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up math --force-recreate

start-server: echo_vars ## Start all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up server --force-recreate

stop: echo_vars ## Stop all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} down

rm-containers: echo_vars ## Remove Docker containers where (polis_tag="${TAG}")
	@echo 'removing filtered containers (polis_tag="${TAG}")'
	@-docker rm -f $(shell docker ps -aq --filter "label=polis_tag=${TAG}")

rm-volumes: echo_vars ## Remove Docker volumes where (polis_tag="${TAG}")
	@echo 'removing filtered volumes (polis_tag="${TAG}")'
	@-docker volume rm -f $(shell docker volume ls -q --filter "label=polis_tag=${TAG}")

rm-images: echo_vars ## Remove Docker images where (polis_tag="${TAG}")
	@echo 'removing filtered images (polis_tag="${TAG}")'
	@-docker rmi -f $(shell docker images -q --filter "label=polis_tag=${TAG}")

rm-ALL: rm-containers rm-volumes rm-images ## Remove Docker containers, volumes, and images (including db) where (polis_tag="${TAG}")
	@echo Done.


build: echo_vars ## [Re]Build all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} build

build-nginx: echo_vars ## [Re]Build all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} build nginx-proxy

build-participa: echo_vars ## [Re]Build all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} build participa

build-no-cache: echo_vars ## Build all Docker containers without cache
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} build --no-cache

start-recreate: echo_vars ## Start all Docker containers with recreated environments
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up --force-recreate

start-recreate-participa: echo_vars ## Start all Docker containers with recreated environments
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up participa --force-recreate

start-recreate-nginx: echo_vars ## Start all Docker containers with recreated environments
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up nginx-proxy --force-recreate

run: echo_vars ## Start all Docker containers with recreated environments
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up -d --force-recreate

start-rebuild: echo_vars ## Start all Docker containers, [re]building as needed
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up --build

start-FULL-REBUILD: echo_vars stop rm-ALL ## Remove and restart all Docker containers, volumes, and images (including db), as with rm-ALL
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} build --no-cache
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} down
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up --build
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} down
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up --build


%:
	@true
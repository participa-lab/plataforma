

SHELL=/bin/bash

export ENV_FILE = polis/dev.env
export TAG = $(shell grep -e ^TAG ${ENV_FILE} | awk -F'[=]' '{gsub(/ /,""); print $$2}')
export COMPOSE_FILE_ARGS = -f docker-compose.yml

init:
	git clone git@github.com:participa-lab/participa.git
	git clone git@github.com:participa-lab/polis.git

update-env:
	cp -R *.env polis/

PROD: ## Run in prod mode (e.g. `make PROD start`, etc.) using config in `prod.env`
	$(eval ENV_FILE = polis/prod.env)
	$(eval TAG = $(shell grep -e ^TAG ${ENV_FILE} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval COMPOSE_FILE_ARGS = -f docker-compose.yml)

TEST: ## Run in test mode (e.g. `make TEST e2e-run`, etc.) using config in `test.env`
	$(eval ENV_FILE = polis/test.env)
	$(eval TAG = $(shell grep -e ^TAG ${ENV_FILE} | awk -F'[=]' '{gsub(/ /,"");print $$2}'))
	$(eval COMPOSE_FILE_ARGS = -f docker-compose.yml -f docker-compose.test.yml)

echo_vars update-env:
	@echo ENV_FILE=${ENV_FILE}
	@echo TAG=${TAG}

pull: echo_vars ## Pull most recent Docker container builds (nightlies)
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} pull

start: echo_vars ## Start all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up

start-sm: echo_vars ## Start all Docker containers
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up server nginx-proxy participa

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

build-no-cache: echo_vars ## Build all Docker containers without cache
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} build --no-cache

start-recreate: echo_vars ## Start all Docker containers with recreated environments
	docker compose ${COMPOSE_FILE_ARGS} --env-file ${ENV_FILE} up --force-recreate

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
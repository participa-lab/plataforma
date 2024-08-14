# Plataforma Participa

This project allows the deployment of pol.is and participa for them to work together.

## Initialize the project

This will clone polis project and participa project, you should do this only once.

```bash
make init
```

## Configure the project

### Env Files

Edit the three .env files for each environment (dev.env, test.env, prod.env) and set the variables of the section "PLATAFORMA PARTICIPA VARIABLES".

Example:

```bash
# PLATAFORMA PARTICIPA VARIABLES
MAIN_DOMAIN = "app.raul"
POLIS_SUBDOMAIN = "polis"
POLIS_DOMAIN = "${POLIS_SUBDOMAIN}.${MAIN_DOMAIN}"

POLIS_GIT_BRANCH = "edge"
POLIS_GIT_SHA=#Empty to use the latest commit of the branch

PARTICIPA_GIT_BRANCH = "main"
PARTICIPA_GIT_SHA=#Empty to use the latest commit of the branch

SERVER_ENV_FILE=dev.env
TAG=dev
COMPOSE_PROJECT_NAME=plataforma-${TAG}

DEV_MODE=true
SERVER_LOG_LEVEL=info

DEBUG=true
```

### Nginx Configuration

Add domain names as server names in `nginx/default.conf`

This will make the polis project to be accessible at polis.app.raul and the main participa project to be accessible at app.raul.

### Note about localhost
Locally, it is better to define a domain for the project in your /etc/hosts file, for example:

```bash
127.0.0.1       app.raul
127.0.0.1       polis.app.raul
```

"localhost" can be problematic in Docker, so it is better to use a domain. 
Remember to flush your DNS cache after editing the /etc/hosts file.

## Development Environment

It's important that the DEV_MODE variable is set to true in the .env file. This relates to pol.is avoiding the use of HTTPS in the development environment.
It's recommended that the DEBUG variable is set to true in the .env file. This will allow you to see the logs of the django server.

To start the development environment, run:

```bash
make start
```

If you change the .env file, you should use after the change:

```bash
make start-recreate
```

If you want to wipe everything (INCLUDING THE DATABASE) and start from scratch, you can use:

```bash
make start-FULL-REBUILD
```

If you want to rebuild a specific service, you can use:

```bash
make build-participa
```

and 

```bash
make start-recreate-participa
```

## Test and Production Environment

It's important that the DEV_MODE variable is set to false in the .env file. This relates to pol.is using HTTPS in the test and production environment.
It's recommended that the DEBUG variable is set to false in the .env file. This will avoid showing the logs of the django server.

To start the test environment, run:

```bash
make TEST run
```

To start the production environment, run:

```bash
make PROD run
```



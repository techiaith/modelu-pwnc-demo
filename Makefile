SHELL ?= $(shell which bash)
USER_ID ?= $(shell id -u)
USER_GID ?= $(shell getent group docker | cut -d: -f3)
MODELS_DIR := ${PWD}/models
VIS_DIR := ${PWD}/visualizations
DOCKER_VOLUMES = ${CACHE_DIR} ${MODELS_DIR} ${VIS_DIR}

include .env

docker-volumes:
	@mkdir -p -m 770 ${DOCKER_VOLUMES}
	@chown ${USER_ID}:${USER_GID} ${DOCKER_VOLUMES}
	@chmod g+s ${DOCKER_VOLUMES}
	@mkdir -p -m 770 ${CACHE_DIR}/torch ${CACHE_DIR}/hf-datasets

${DOCKER_VOLUMES}: docker-volumes

build: ${DOCKER_VOLUMES}
	@docker build --build-arg USER_GID=${USER_GID} \
                  --build-arg USER_ID=${USER_ID} \
				  --build-arg USER_NAME=${DOCKER_USER} \
                  --rm -t ${DOCKER_IMG_TAG} .

uninstall:
	@docker image rm ${DOCKER_IMG_TAG}

destroy: unisntall
	@rm -rf ${DOCKER_VOLUMES}


default: build

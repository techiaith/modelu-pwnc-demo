#!/usr/bin/bash
proj_root_dir=$(realpath $(dirname "${BASH_SOURCE[0]}")/..)
set -eof pipefail

set -a
source ${proj_root_dir}/.env
set +a

docker run -it --rm --privileged \
       --mount type=bind,src=${CACHE_DIR},dst=/app/cache \
       --mount type=bind,src=${PWD}/config,dst=/app/config \
       --mount type=bind,src=${PWD}/models,dst=/models \
       --mount type=bind,src=${PWD}/visualizations,dst=/visualizations \
       --mount type=bind,src=${PWD}/src,dst=/app/src \
       --user ${DOCKER_USER} \
       --name ${DOCKER_CONTAINER_NAME} \
       --workdir /app \
       --runtime=nvidia \
       --publish 127.0.0.1:${BROWSE_VIZ_PORT}:${BROWSE_VIZ_PORT} \
       ${DOCKER_IMG_TAG} \
       micromamba run -n base $@
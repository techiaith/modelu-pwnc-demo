#!/usr/bin/bash
set -eof pipefail

proj_root_dir=$(realpath $(dirname "${BASH_SOURCE[0]}")/..)

# Read environment variables.
set -a
source ${proj_root_dir}/.env
set +a

${proj_root_dir}/scripts/docker_run.sh python -m http.server \
  --bind=${BROWSE_VIZ_IP} \
  --directory=/visualizations \
  ${BROWSE_VIZ_PORT}

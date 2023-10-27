FROM mambaorg/micromamba:1-focal-cuda-12.2.0

ARG USER_ID
ARG USER_GID
ARG USER_NAME="mambauser"

ENV DEBIAN_FRONTEND=noninteractive

USER root
RUN apt update && \
    apt install -y \
    curl git build-essential \
    g++ protobuf-compiler libprotobuf-dev \
    libxml2-dev libxslt1-dev \
    mime-support python3-dev

RUN usermod "--login=${USER_NAME}" "--home=/home/${USER_NAME}" \
    --move-home "-u ${USER_ID}" "${USER_NAME}" && \
    groupmod "--new-name=${USER_NAME}" \
    "-g ${USER_GID}" "${USER_NAME}" && \
    echo "${USER_NAME}" > "/etc/arg_mamba_user" && \
    :

# Cache directory for sentence-transformers models
ENV TORCH_HOME=/app/cache/torch
ENV HF_DATASETS_CACHE=/app/cache/hf-datasets
RUN mkdir -p -m 770 ${TORCH_HOME} ${HF_DATASETS_CACHE}
RUN chown -R ${USER_NAME}:${USER_NAME} ${TORCH_HOME} ${HF_DATASETS_CACHE}
RUN chmod ug=rwx ${TORCH_HOME} ${HF_DATASETS_CACHE}

USER ${USER_NAME}

COPY --chown=${USER_NAME}:${USER_GID} src/ /app/src/
COPY --chown=${USER_NAME}:${USER_GID} requirements.txt /tmp
COPY --chown=${USER_NAME}:${USER_GID} config/docker-env.yaml /tmp/env.yaml

# Install the application and its dependencies.
RUN micromamba install -n base -y --file /tmp/env.yaml && \
    micromamba clean -a -y

RUN micromamba run -n base pip install "pandas>=2.1"

ENV TOKENIZERS_PARALLELISM=false

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
SHELL ["/usr/local/bin/_dockerfile_shell.sh"]
CMD ["/bin/bash"]

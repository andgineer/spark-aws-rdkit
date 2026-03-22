FROM andgineer/spark-aws

# set by Docker Buildx
ARG TARGETPLATFORM

ARG CONDA_VERSION=py313_26.1.1-1
ARG CONDA_SHA256_x86_64="f6dfb5b59614fd7b2956b240b2575a9d58203ec7f7a99f85128158a0fdc5c1d7"
ARG CONDA_SHA256_aarch64="07c82b5aec04d5f0f3e4b246835b6bc85e104821cbcb0a059c7ea80f028503f4"

ARG CONDA_ENV=spark

ARG USER_NAME=spark

USER root

RUN apt-get update -q && \
    apt-get install -q -y \
        bzip2 ca-certificates git libglib2.0-0 libsm6 libxext6 libxrender1 libarchive13 mercurial subversion wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading Miniconda3-${CONDA_VERSION} for ${TARGETPLATFORM}..." \
    && CONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-" \
    && CONDA_SHA256="" \
    && if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
         CONDA_URL="${CONDA_URL}x86_64.sh"; \
         CONDA_SHA256=${CONDA_SHA256_x86_64}; \
       elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
         CONDA_URL="${CONDA_URL}aarch64.sh"; \
         CONDA_SHA256=${CONDA_SHA256_aarch64}; \
       else \
         echo "Unsupported platform: ${TARGETPLATFORM}"; \
         exit 1; \
       fi \
    && wget --quiet ${CONDA_URL} -O miniconda.sh \
    && echo "${CONDA_SHA256} *miniconda.sh" | sha256sum -c - || { echo "Miniconda checksum check failed"; exit 1; } \
    && mkdir -p /opt \
    && sh miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && /opt/conda/bin/conda clean -afy \
    && chown -R $USER_NAME /opt/conda && chmod -R g+rwx /opt/conda/

USER $USER_NAME
COPY --chown=${USER_NAME} environment.yml /envs/
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "source activate $CONDA_ENV" >> ~/.bashrc \
    && /opt/conda/bin/conda config --system --remove channels defaults \
    && /opt/conda/bin/conda install 'mamba>=2.3.0' -n base -c conda-forge \
    && /opt/conda/bin/conda info --envs \
    && /opt/conda/bin/mamba env create --file /envs/environment.yml

VOLUME /python

ENV PATH=/opt/conda/envs/$CONDA_ENV/bin:/opt/conda/bin:$PATH
ENV CONDA_DEFAULT_ENV=$CONDA_ENV
ENV PYTHONPATH=${SPARK_HOME}/python/:$SPARK_HOME/python/lib:/python/


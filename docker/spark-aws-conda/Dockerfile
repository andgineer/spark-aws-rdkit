FROM andgineer/spark-aws

ARG CONDA_VERSION=py37_4.9.2
ARG CONDA_MD5=3143b1116f2d466d9325c206b7de88f7
ARG CONDA_ENV=spark

RUN apt-get update -q && \
    apt-get install -q -y \
        bzip2 ca-certificates git libglib2.0-0 libsm6 libxext6 libxrender1 mercurial subversion wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh \
    && echo "${CONDA_MD5}  miniconda.sh" > miniconda.md5 \
    && if ! md5sum --status -c miniconda.md5; then exit 1; fi \
    && mkdir -p /opt \
    && sh miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh miniconda.md5 \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete \
    && /opt/conda/bin/conda clean -afy

ENV PATH /opt/conda/bin:$PATH

COPY environment.yml /
RUN conda install mamba -n base -c conda-forge \
    && mamba env create --file /environment.yml \
    && conda info --envs \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "source activate $CONDA_ENV" >> ~/.bashrc

ENV PATH /opt/conda/envs/$CONDA_ENV/bin:$PATH
ENV CONDA_DEFAULT_ENV $CONDA_ENV
ENV PYTHONPATH $SPARK_HOME/python/lib:$PYTHONPATH

FROM andgineer/spark-aws-conda

ARG CONDA_ENV=spark
ARG USER_NAME=spark

COPY --chown=${USER_NAME}  environment.yml /envs/environment.yml
RUN conda info --envs \
    && mamba env update --name "$CONDA_ENV" --file /envs/environment.yml




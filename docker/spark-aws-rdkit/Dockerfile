FROM andgineer/spark-aws-conda

ARG CONDA_ENV=spark
ARG USER_NAME=spark

COPY --chown=${USER_NAME} environment.yml /envs/environment.yml
RUN echo "=== solver ===" \
    && conda config --show solver \
    && echo "=== envs_dirs ===" \
    && conda config --show envs_dirs \
    && echo "=== before update ===" \
    && conda info --envs \
    && conda env update --name "$CONDA_ENV" --file /envs/environment.yml \
    && echo "=== after update ===" \
    && conda info --envs \
    && conda clean -ay \
    && conda list --name "$CONDA_ENV"





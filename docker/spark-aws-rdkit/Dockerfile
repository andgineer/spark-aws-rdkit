FROM andgineer/spark-aws-conda

ARG CONDA_ENV=spark

COPY environment.yml /
RUN mamba env update --name "$CONDA_ENV" --file /environment.yml




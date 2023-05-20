FROM andgineer/spark-aws-rdkit

ARG USER_NAME=spark

USER root

COPY --chown=${USER_NAME} start.sh /scripts/
RUN chmod +x /scripts/start.sh

USER $USER_NAME

SHELL ["/bin/bash", "-c"]
WORKDIR /python
CMD /scripts/start.sh




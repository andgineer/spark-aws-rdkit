#!/bin/bash

# shellcheck disable=SC2001
HOST="$(echo "$SPARK_MASTER_URL" | sed 's@spark://\([^:]*\):\([0-9]\{2,4\}\)@\1@')"
# shellcheck disable=SC2001
PORT="$(echo "$SPARK_MASTER_URL" | sed 's@spark://\([^:]*\):\([0-9]\{2,4\}\)@\2@')"
echo "Waiting for ${HOST}:${PORT} (Spark URL $SPARK_MASTER_URL)"
until echo -e '\x1dclose\x0d' | telnet ${HOST} ${PORT}; do
  echo "Spark Driver is not ready - waiting"
  sleep 2
done

printf "\n\n>>>>> Spark Driver is up <<<<<\n\n"

python /python/health_check.py $SPARK_MASTER_URL

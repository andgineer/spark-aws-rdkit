#!/bin/bash

until echo -e '\x1dclose\x0d' | telnet spark-master 7077; do
  echo "Spark Driver is not ready - waiting"
  sleep 2
done

printf "\n\n>>>>> Spark Driver is up <<<<<\n\n"

python /python/health_check.py spark://spark-master:7077
# todo looks like a hack (we get last IP from all host IPs)
# may be we need more reliable way to get instance IP reachable in subnet
LOCAL_IP=$(hostname -I | awk '{print $(NF)}')
echo "Detected Spark node IP as ${LOCAL_IP}"
echo "User group: $USER_GROUP"
echo "User: $(whoami)"

# Spark UI web-links:
export SPARK_PUBLIC_DNS=${SPARK_PUBLIC_DNS:-$LOCAL_IP}

# Worker unique names - without that all workers connect to master with the same name and master make them reconnect
export SPARK_LOCAL_HOSTNAME=$LOCAL_IP

if [ "${SPARK_MODE}" = "master" ]; then
  echo "##### Start as Spark master"
  bin/spark-class org.apache.spark.deploy.master.Master
else
  echo "##### Start as Spark slave"
  bin/spark-class org.apache.spark.deploy.worker.Worker ${SPARK_MASTER_URL}
fi

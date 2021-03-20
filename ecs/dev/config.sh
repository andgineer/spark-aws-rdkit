export AWS_PAGER=""  # suppress using `less` in aws CLI

export CLUSTER_NAME="spark"
export SPARK_MASTER_DNS="spark-master"
export BALANCER_NAME="spark-dev"
export WEBUI_TARGET_NAME="webui-target"
export REST_TARGET_NAME="rest-target"

export CLOUD_WATCH_GROUP="/spark"
export CLOUD_WATCH_REGION="us-east-1"

export AWS_ACCOUNT_ID="???"
export VPC_ID="???"
export SUBNETS=("subnet-???" "subnet-???")
export WORKER_SECURITY_GROUPS=("sg-???" "sg-???")
export MASTER_SECURITY_GROUPS=("sg-???" "sg-???")
export NAMESPACE_ID="ns-???"
export NAMESPACE_NAME="???"

export MASTER_SERVICE_DISCOVERY_NAME="$SPARK_MASTER_DNS.$NAMESPACE_NAME"

export WORKER_IMAGE="${AWS_ACCOUNT_ID}.???.amazonaws.com/spark-aws-rdkit"
export MASTER_IMAGE="${AWS_ACCOUNT_ID}.???.amazonaws.com/spark-aws-rdkit"
export SUBMIT_IMAGE="${AWS_ACCOUNT_ID}.???.amazonaws.com/spark-aws-rdkit"

export MASTER_CONF_FOLDER="/conf/master"
export WORKER_CONF_FOLDER="/conf/worker"

export SPARK_WORKERS_NUMBER=5
# "1024 CPU" means one CPU
export MASTER_CPU="1024"
export MASTER_MEMORY_MB="2048"
export WORKER_CPU="1024"
export WORKER_MEMORY_MB="2048"
export SUBMIT_CPU="1024"
export SUBMIT_MEMORY_MB="2048"

export SPARK_REST_PORT=81
export SPARK_WEBUI_PORT=80


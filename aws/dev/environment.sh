export AWS_PAGER=""  # suppress using `less` in aws CLI

export CLUSTER="spark"
export MASTER_NAME="spark-master"
export ELB_NAME="spark-dev"
export ELB_SUBMIT_NAME="SparkSubmit"
export ELB_UI_NAME="SparkUI"

export CLOUD_WATCH_GROUP="/ecs/spark"
export CLOUD_WATCH_REGION="us-east-1"

export AWS_ACCOUNT_ID="???"
export VPC_ID="???"
export SUBNETS=("subnet-???" "subnet-???")
export SECURITY_GROUPS=("sg-???" "sg-???")
export SPARK_MASTER_SECURITY_GROUPS=("sg-???" "sg-???")
export NAMESPACE_ID="ns-???"
export NAMESPACE_NAME="???"

export MASTER_FULL_NAME="$MASTER_NAME.$NAMESPACE_NAME"

export WORKER_IMAGE="${AWS_ACCOUNT_ID}.???.amazonaws.com/spark-aws-rdkit"
export MASTER_IMAGE="${AWS_ACCOUNT_ID}.???.amazonaws.com/spark-aws-rdkit"
export SUBMIT_IMAGE="${AWS_ACCOUNT_ID}.???.amazonaws.com/spark-aws-rdkit"

export MASTER_CONF_FOLDER="/conf/driver"
export WORKER_CONF_FOLDER="/conf/worker"

export SPARK_WORKERS_NUMBER=10
# "1024 CPU" means one CPU
export MASTER_CPU="1024"
export MASTER_MEMORY_MB="4096"
export WORKER_CPU="1024"
export WORKER_MEMORY_MB="4096"
export SUBMIT_CPU="1024"
export SUBMIT_MEMORY_MB="4096"

export SPARK_EXTERNAL_PORT=81
export SPARK_UI_PORT=80


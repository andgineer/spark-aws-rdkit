#! /usr/bin/env bash

echo "Create and run Apache Spark cluster on Amazon ECS cluster"
AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
echo " <<<<< AWS account: $AWS_ACCOUNT >>>>>"
source aws/${AWS_ACCOUNT}/environment.sh
source aws/ecs_funcs.sh

echo "Create service discovery service"
SERVICEDISCOVERY_ARN=$(aws servicediscovery create-service --name ${MASTER_NAME} \
  --dns-config "NamespaceId=${NAMESPACE_ID},DnsRecords=[{Type=A,TTL=600}]" \
  | grep -o '"Arn": "arn:aws:servicediscovery:[^"]\+"' \
  | sed -E 's/"Arn": "(.*)"/\1/')

aws/create_elb.sh

echo "Create cluster ${CLUSTER}"
aws ecs create-cluster --cluster-name "${CLUSTER}" > /dev/null

echo "Create Spark Driver task definition"
TASK_DESCR_FILE=$(substitute_vars "aws/${AWS_ACCOUNT}/spark-master-task.json")
aws ecs register-task-definition --cli-input-json "file://$TASK_DESCR_FILE" > /dev/null
rm "$TASK_DESCR_FILE"

echo "Create Spark Driver service for the task $(last_task_def 'spark-master') with target groups $ELB_UI_NAME and $ELB_SUBMIT_NAME"
aws ecs create-service --cluster "${CLUSTER}" \
    --service-registries="registryArn=${SERVICEDISCOVERY_ARN}" \
    --cli-input-json '{"loadBalancers": [
    {
        "targetGroupArn": "'"$(elb_target_arn $ELB_SUBMIT_NAME)"'",
        "containerName": "spark-master",
        "containerPort": 7077
    },
    {
        "targetGroupArn": "'"$(elb_target_arn $ELB_UI_NAME)"'",
        "containerName": "spark-master",
        "containerPort": 8080
    }
    ]}' \
    --service-name spark-master-service \
    --task-definition "$(last_task_def 'spark-master')" \
    --desired-count 1 \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[$(join , "${SUBNETS[@]}")], \
      securityGroups=[$(join , "${SPARK_MASTER_SECURITY_GROUPS[@]}")]}" \
    > /dev/null

echo "Create Spark Executor task definition"
TASK_DESCR_FILE=$(substitute_vars "aws/${AWS_ACCOUNT}/spark-worker-task.json")
aws ecs register-task-definition --cli-input-json "file://$TASK_DESCR_FILE" > /dev/null
rm "$TASK_DESCR_FILE"

echo "Create Spark Executors service"
aws ecs create-service --cluster "${CLUSTER}" \
    --service-name spark-worker-service \
    --task-definition "$(last_task_def 'spark-worker')" \
    --desired-count $SPARK_WORKERS_NUMBER \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[$(join , "${SUBNETS[@]}")], \
      securityGroups=[$(join , "${SECURITY_GROUPS[@]}")]}" \
    > /dev/null

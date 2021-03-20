#! /usr/bin/env bash

echo "Create and run Apache Spark cluster on Amazon ECS cluster"
AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
echo " ***** AWS account: $AWS_ACCOUNT *****"
source "ecs/${AWS_ACCOUNT}/config.sh"
source ecs/aws_funcs.sh

echo "Create service discovery service"
SERVICEDISCOVERY_ARN=$(aws servicediscovery create-service --name ${SPARK_MASTER_DNS} \
  --dns-config "NamespaceId=${NAMESPACE_ID},DnsRecords=[{Type=A,TTL=600}]" \
  | grep -o '"Arn": "arn:aws:servicediscovery:[^"]\+"' \
  | sed -E 's/"Arn": "(.*)"/\1/')

echo "Create target group $REST_TARGET_NAME"
aws elbv2 create-target-group \
  --name $REST_TARGET_NAME \
  --protocol TCP \
  --port 6066 \
  --health-check-port 8080 \
  --health-check-protocol TCP \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 10 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 2 \
  --vpc-id $VPC_ID \
  --target-type ip \
  > /dev/null

echo "Create target group $WEBUI_TARGET_NAME"
aws elbv2 create-target-group \
  --name $WEBUI_TARGET_NAME \
  --protocol TCP \
  --port 8080 \
  --vpc-id $VPC_ID \
  --target-type ip \
  > /dev/null

echo "Create load balancer $BALANCER_NAME"
aws elbv2 create-load-balancer \
  --name $BALANCER_NAME \
  --subnets $(join " " "${SUBNETS[@]}") \
  --scheme internal \
  --type network \
  --ip-address-type ipv4 \
  > /dev/null

echo "Create $REST_TARGET_NAME listener"
aws elbv2 create-listener --load-balancer-arn "$(elb_arn $BALANCER_NAME)" \
  --protocol TCP --port "${SPARK_REST_PORT}" \
  --default-actions Type=forward,TargetGroupArn="$(elb_target_arn $REST_TARGET_NAME)" \
  > /dev/null

echo "Create $WEBUI_TARGET_NAME listener"
aws elbv2 create-listener --load-balancer-arn "$(elb_arn $BALANCER_NAME)" \
  --protocol TCP --port "$SPARK_WEBUI_PORT" \
  --default-actions Type=forward,TargetGroupArn="$(elb_target_arn $WEBUI_TARGET_NAME)" \
  > /dev/null

echo "Create cluster ${CLUSTER_NAME}"
aws ecs create-cluster --cluster-name "${CLUSTER_NAME}" > /dev/null

echo "Create Spark Driver task definition"
TASK_DESCR_FILE=$(substitute_vars "ecs/${AWS_ACCOUNT}/spark-master-task.json")
aws ecs register-task-definition --cli-input-json "file://$TASK_DESCR_FILE" > /dev/null
rm "$TASK_DESCR_FILE"

echo "Create Spark Driver service for the task $(last_task_def 'spark-master') with target groups $WEBUI_TARGET_NAME and $REST_TARGET_NAME"
aws ecs create-service --cluster "${CLUSTER_NAME}" \
    --service-registries="registryArn=${SERVICEDISCOVERY_ARN}" \
    --cli-input-json '{"loadBalancers": [
    {
        "targetGroupArn": "'"$(elb_target_arn $REST_TARGET_NAME)"'",
        "containerName": "spark-master",
        "containerPort": 6066
    },
    {
        "targetGroupArn": "'"$(elb_target_arn $WEBUI_TARGET_NAME)"'",
        "containerName": "spark-master",
        "containerPort": 8080
    }
    ]}' \
    --service-name spark-master-service \
    --task-definition "$(last_task_def 'spark-master')" \
    --desired-count 1 \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[$(join , "${SUBNETS[@]}")], \
      securityGroups=[$(join , "${MASTER_SECURITY_GROUPS[@]}")]}" \
    > /dev/null

echo "Create Spark Executor task definition"
TASK_DESCR_FILE=$(substitute_vars "ecs/${AWS_ACCOUNT}/spark-worker-task.json")
aws ecs register-task-definition --cli-input-json "file://$TASK_DESCR_FILE" > /dev/null
rm "$TASK_DESCR_FILE"

echo "Create Spark Executors service"
aws ecs create-service --cluster "${CLUSTER_NAME}" \
    --service-name spark-worker-service \
    --task-definition "$(last_task_def 'spark-worker')" \
    --desired-count $SPARK_WORKERS_NUMBER \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[$(join , "${SUBNETS[@]}")], \
      securityGroups=[$(join , "${WORKER_SECURITY_GROUPS[@]}")]}" \
    > /dev/null

#! /usr/bin/env bash
# Creates load balancer, target groups

AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
source aws/${AWS_ACCOUNT}/environment.sh
source aws/ecs_funcs.sh

# NLB fires heath check every second despite `health-check-interval-seconds` and so it spams Spark logs
# https://forums.aws.amazon.com/thread.jspa?threadID=266796
# to keep logs clear we use WebUI port as health check
echo "Create target group $ELB_SUBMIT_NAME"
aws elbv2 create-target-group \
  --name $ELB_SUBMIT_NAME \
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

echo "Create target group $ELB_UI_NAME"
aws elbv2 create-target-group \
  --name $ELB_UI_NAME \
  --protocol TCP \
  --port 8080 \
  --vpc-id $VPC_ID \
  --target-type ip \
  > /dev/null

echo "Create load balancer $ELB_NAME"
aws elbv2 create-load-balancer \
  --name $ELB_NAME \
  --subnets $(join " " "${SUBNETS[@]}") \
  --scheme internal \
  --type network \
  --ip-address-type ipv4 \
  > /dev/null

echo "Create $ELB_SUBMIT_NAME listener"
aws elbv2 create-listener --load-balancer-arn "$(elb_arn $ELB_NAME)" \
  --protocol TCP --port "${SPARK_EXTERNAL_PORT}" \
  --default-actions Type=forward,TargetGroupArn="$(elb_target_arn $ELB_SUBMIT_NAME)" \
  > /dev/null

echo "Create $ELB_UI_NAME listener"
aws elbv2 create-listener --load-balancer-arn "$(elb_arn $ELB_NAME)" \
  --protocol TCP --port "$SPARK_UI_PORT" \
  --default-actions Type=forward,TargetGroupArn="$(elb_target_arn $ELB_UI_NAME)" \
  > /dev/null

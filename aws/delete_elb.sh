#! /usr/bin/env bash
# Deletes load balancer and target groups

AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
source aws/${AWS_ACCOUNT}/environment.sh
source aws/ecs_funcs.sh

echo "Delete listeners"
for LISTENER in $(listeners_arns $ELB_NAME); do
  echo "Delete listener $LISTENER"
  aws elbv2 delete-listener --listener-arn "$LISTENER"
done

for TARGET_NAME in $ELB_UI_NAME $ELB_SUBMIT_NAME; do
  echo "Delete target group $TARGET_NAME"
  aws elbv2 delete-target-group \
    --target-group-arn "$(elb_target_arn $TARGET_NAME)"
done

echo "Delete load balancer $ELB_NAME"
aws elbv2 delete-load-balancer \
  --load-balancer-arn "$(elb_arn $ELB_NAME)"

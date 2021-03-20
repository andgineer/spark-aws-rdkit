#! /usr/bin/env bash
echo "Shut down cluster ${CLUSTER_NAME} and clean up all Amazon ECS resources"

AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
echo " ***** AWS account: $AWS_ACCOUNT *****"
source "ecs/${AWS_ACCOUNT}/config.sh"

read -r -p "Are you sure? [y/N] " response
if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Aborted"
    echo "At the moment there are clusters:"
    aws ecs list-clusters
    exit
fi

echo "..inactivating Spark Worker services.."
aws ecs delete-service --cluster ${CLUSTER_NAME} --service spark-worker-service --force > /dev/null

echo "..waiting Spark Worker inactivation.."
aws ecs wait services-inactive --cluster ${CLUSTER_NAME} \
    --services spark-worker-service \
    > /dev/null

echo "..inactivating Spark Master service.."
aws ecs delete-service --cluster ${CLUSTER_NAME} --service spark-master-service --force > /dev/null

echo "..waiting spark master service to inactivation.."
aws ecs wait services-inactive --cluster ${CLUSTER_NAME} \
    --services spark-master-service \
    > /dev/null

echo "remaining services in the cluster ${CLUSTER_NAME}:"
aws ecs list-services --cluster ${CLUSTER_NAME}

echo "..deregistering task definitions.."
for TASK_NAME in "spark-master" "spark-submit" "spark-worker"; do
  for TASK_ARN in $(aws ecs list-task-definitions --family-prefix ${TASK_NAME} --output text); do
    if ! [[ $TASK_ARN = "TASKDEFINITIONARNS" ]]; then
      aws ecs deregister-task-definition --task-definition ${TASK_ARN} > /dev/null
    fi
  done
done

echo "remaining task definitions in the AWS account:"
aws ecs list-task-definitions

echo "..control shot to stop tasks in the cluster ${CLUSTER_NAME}.."
for TASK_ARN in $(aws ecs list-tasks --cluster ${CLUSTER_NAME} --output text); do
      if ! [[ $TASK_ARN = "TASKARNS" ]]; then
        aws ecs stop-task --cluster "${CLUSTER_NAME}" --task "${TASK_ARN}" > /dev/null
      fi
done

echo "..removing the cluster ${CLUSTER_NAME}.."
aws ecs delete-cluster --cluster ${CLUSTER_NAME} > /dev/null

echo "..removing service discovery service.."
for SERVICEDISCOVERY_ID in $(aws servicediscovery list-services \
  --filters "Name=NAMESPACE_ID,Values=${NAMESPACE_ID}" \
  | grep -o '"Id": "[^"]\+"' \
  | sed -E 's/"Id": "(.*)"/\1/'); do
  aws servicediscovery delete-service --id "${SERVICEDISCOVERY_ID}"
done


echo "..removing listeners.."
for LISTENER in $(listeners_arns $BALANCER_NAME); do
  echo "Delete listener $LISTENER"
  aws elbv2 delete-listener --listener-arn "$LISTENER"
done

for TARGET_NAME in $WEBUI_TARGET_NAME $REST_TARGET_NAME; do
  echo "Delete target group $TARGET_NAME"
  aws elbv2 delete-target-group \
    --target-group-arn "$(elb_target_arn $TARGET_NAME)"
done

echo "..removing load balancer $BALANCER_NAME .."
aws elbv2 delete-load-balancer \
  --load-balancer-arn "$(elb_arn $BALANCER_NAME)"


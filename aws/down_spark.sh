#! /usr/bin/env bash
echo "Shut down cluster ${CLUSTER} and clean up all Amazon ECS resources"

AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
echo " <<<<< AWS account: $AWS_ACCOUNT >>>>>"
source aws/${AWS_ACCOUNT}/environment.sh

read -r -p "Are you sure? [y/N] " response
if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Aborted"
    echo "At the moment there are clusters:"
    aws ecs list-clusters
    exit
fi

echo "..shutting down spark worker services.."
aws ecs delete-service --cluster ${CLUSTER} --service spark-worker-service --force > /dev/null

echo "..waiting worker services to stop.."
aws ecs wait services-inactive --cluster ${CLUSTER} \
    --services spark-worker-service \
    > /dev/null

echo "..shutting down spark-master service.."
aws ecs delete-service --cluster ${CLUSTER} --service spark-master-service --force > /dev/null

echo "..waiting spark master service to stop.."
aws ecs wait services-inactive --cluster ${CLUSTER} \
    --services spark-master-service \
    > /dev/null

echo "current list of services in the cluster ${CLUSTER}:"
aws ecs list-services --cluster ${CLUSTER}

echo "..delete task definitions.."
for TASK_NAME in "spark-master" "spark-submit" "spark-worker"; do
  for TASK_ARN in $(aws ecs list-task-definitions --family-prefix ${TASK_NAME} --output text); do
    if ! [[ $TASK_ARN = "TASKDEFINITIONARNS" ]]; then
      aws ecs deregister-task-definition --task-definition ${TASK_ARN} > /dev/null
    fi
  done
done

echo "current list of task definitions in the AWS account:"
aws ecs list-task-definitions

echo "..stop all left tasks in the cluster ${CLUSTER} if some were stuck.."
for TASK_ARN in $(aws ecs list-tasks --cluster ${CLUSTER} --output text); do
      if ! [[ $TASK_ARN = "TASKARNS" ]]; then
        aws ecs stop-task --cluster "${CLUSTER}" --task "${TASK_ARN}" > /dev/null
      fi
done

echo "..delete the cluster ${CLUSTER}.."
aws ecs delete-cluster --cluster ${CLUSTER} > /dev/null

echo "..delete service discovery service.."
for SERVICEDISCOVERY_ID in $(aws servicediscovery list-services \
  --filters "Name=NAMESPACE_ID,Values=${NAMESPACE_ID}" \
  | grep -o '"Id": "[^"]\+"' \
  | sed -E 's/"Id": "(.*)"/\1/'); do
  aws servicediscovery delete-service --id "${SERVICEDISCOVERY_ID}"
done

aws/delete_elb.sh

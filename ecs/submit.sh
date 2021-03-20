#! /usr/bin/env bash

echo "Submit task to Spark cluster"
AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
echo " ***** AWS account: $AWS_ACCOUNT *****"
source ecs/${AWS_ACCOUNT}/config.sh
source ecs/aws_funcs.sh

echo "Create Submit task definition"
TASK_DESCR_FILE=$(substitute_vars "ecs/${AWS_ACCOUNT}/spark-submit-task.json")
aws ecs register-task-definition --cli-input-json "file://$TASK_DESCR_FILE" \
  | grep -o '"taskDefinitionArn": "[^"]*"'
rm "$TASK_DESCR_FILE"

echo "Run Submit task"
TASK_ARN=$(aws ecs run-task --cluster "${CLUSTER_NAME}" \
    --task-definition "$(last_task_def 'spark-submit')" \
    --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=[$(join , "${SUBNETS[@]}")], \
      securityGroups=[$(join , "${WORKER_SECURITY_GROUPS[@]}")]}" \
    | grep -o ' "taskArn": "arn:aws:ecs:[^"]*"' \
    | sed -E 's/"taskArn": "(.*)"/\1/' \
    | tail -1)  # taskArn is included more than one time in the task description

echo "TaskArn: $TASK_ARN"

echo "Waiting for the task ($TASK_ARN) to complete"
while sleep 3; do
  STATUS="$(task_status $TASK_ARN)"
  [[ "$STATUS" != "STOPPED" ]] || break
  echo "The task is in $STATUS state - waiting"
done

echo "Task was finished with $STATUS state"

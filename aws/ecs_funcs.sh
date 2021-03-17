#! /usr/bin/env bash
# Functions for ASW ECS cluster

source aws/${AWS_ACCOUNT}/environment.sh

function last_task_def () {
  # returns the latest definition for task with name from the func argument
  aws ecs list-task-definitions --output text \
        | grep -o "$1:[0-9]\+" \
        | tail -1
}

function elb_target_arn () {
  # returns ARN for the target group with name in the func argument
  aws elbv2 describe-target-groups --names $1 \
    | grep -o '"TargetGroupArn": "arn:aws:elasticloadbalancing:[^"]\+"' \
    | sed -E 's/"TargetGroupArn": "(.*)"/\1/'
}

function join () {
  # Join array ($2) items with separator ($1)
  local IFS="$1"  # set internal field separator locally so we wont break the world
  shift  # now $2 becomes $1
  echo "$*"  # print second argument as array
}

function elb_arn () {
  # returns ARN for load balancer with name in first argument
  aws elbv2 describe-load-balancers --names $1 \
    | grep -o '"LoadBalancerArn": "arn:aws:elasticloadbalancing:[^"]\+"' \
    | sed -E 's/"LoadBalancerArn": "(.*)"/\1/'
}


function elb_dns () {
  # returns DNS name for load balancer with name in first argument
  aws elbv2 describe-load-balancers --names $1 \
    | grep -o '"DNSName": "[^"]\+"' \
    | sed -E 's/"DNSName": "(.*)"/\1/'
}

function listeners_arns () {
  # returns ARNs for listeners of load balancer with name in first argument
  aws elbv2 describe-listeners --load-balancer-arn "$(elb_arn $1)" \
    | grep -o '"ListenerArn": "arn:aws:elasticloadbalancing:[^"]\+"' \
    | sed -E 's/"ListenerArn": "(.*)"/\1/'
}

#function task_definition_arn () {
#  | grep -o '"taskDefinitionArn": "[^"]*"'
#  }

function substitute_vars () {
  # Get file as $1, create copy of it in temp folder and substitute in the copy all env vars defined in
  # current session to placeholders in source file like ${name}
  # Returns the temp file name
  # Calling process should delete it afterwards
  TMP_FILE=$(mktemp)
  cp "$1" "${TMP_FILE}"
  for VAR in $(compgen -e); do
    # We cannot use "sed -i" because there is three incompatible version - old and new MacOS and GNU
    # And we cannot copy the file to itself instead of "-i".
    # So we need this second temp file.
    TMP_FILE2=$(mktemp)
    if [ -n "$ZSH_VERSION" ] && type zstyle >/dev/null 2>&1; then # ZSH
      # ZSH
      sed 's|${'$VAR'}|'${(P)VAR}'|g' "${TMP_FILE}" > "${TMP_FILE2}" && mv "${TMP_FILE2}" "${TMP_FILE}"
    else # should be BASH
      # BASH
      sed 's|${'$VAR'}|'"${!VAR}"'|g' "${TMP_FILE}" > "${TMP_FILE2}" && mv "${TMP_FILE2}" "${TMP_FILE}"
    fi
  done
  echo ${TMP_FILE}
}

function task_status () {
  # Return Status (PROVISIONING/PENDING/RUNNING/DEPROVISIONING/STOPPED) of the task container for a task with ARN in $1
  aws ecs describe-tasks --cluster "${CLUSTER}" --tasks "$1" \
    | grep -o '"lastStatus": "[^"]\+"' \
    | sed -E 's/"lastStatus": "(.*)"/\1/' \
    | tail -1  # there is status of the container with the same name
}
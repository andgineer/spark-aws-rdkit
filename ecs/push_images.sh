#! /usr/bin/env bash

echo "Push docker images to Amazon ECR"
AWS_ACCOUNT=${AWS_ACCOUNT:-"dev"}
echo " ***** AWS account: $AWS_ACCOUNT *****"
source "ecs/${AWS_ACCOUNT}/config.sh"
source ecs/aws_funcs.sh

read -r -p "Are you sure? [y/N] " response
if ! [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "Aborted"
    echo "At the moment there are images:"
    docker images --filter=reference="${NAMESPACE_NAME}-*:*"
    exit
fi

ecs-cli push andgineer/spark-aws-rdkit

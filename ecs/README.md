# Architecture

Deploy to Amazon ECS Apache Spark Standalone cluster 
(one Spark Master and fixed number `$SPARK_WORKERS_NUMBER` of Spark Workers).

See configuration in `ecs/dev/config.sh`.

Spark Master registered in AWS Cloud Map - service discovery service, with fixed name `spark-master`.
Spark Workers look for master by this name.

We use network load balancer to forward requests from clients external to AWS cloud to the Spark Master.

Spark Master has external REST API port `SPARK_REST_PORT` and
Spark WebUI port - `SPARK_WEBUI_PORT`. 

DNS name can be found in the load balancer description.
Open [Load balancers list in AWS EC2](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LoadBalancers:sort=loadBalancerName)
and find the balancer with the name `$BALANCER_NAME`.

Spark Web UI is not fully functional - the links to workers WebUI would not work.
Is is possible to make them work with solutions like [Spark UI proxy](https://github.com/aseigneurin/spark-ui-proxy).

But actually we do not have to because all worker logs are available in AWS Cloud Watch.
You can control logs levels with `log4j.properties` files in Spark conf.

# Deploy and run

Download Docker images:

    docker pull andgineer/spark-aws-rdkit

Push the images to AWS registry (ECR):

    ecs/push_images.sh

Create and start Spark cluster in AWS ECS using this images:

    ecs/create_cluster.sh

Run submit container `docker/submit` on the cluster

    ecs/submit.sh

Stop Spark cluster and delete all resources including load balancer - but not the
Docker images in AWS ECR.

    ecs/delete_cluster.sh

# Configurations

You can create separate environments folders in `ecs/` for different environments like `dev` / `prd` / `tst`.

By default it is `dev`.

# Load balancer

We use load balancer `$BALANCER_NAME` as entry point for Spark Master server.

It has two listeners: Spark REST API `$REST_TARGET_NAME` - port `$SPARK_REST_PORT` and
webUI `$WEBUI_TARGET_NAME` - port `$SPARK_WEBUI_PORT`.

To get DNS name you can use function `elb_dns` from `aws_funcs.sh` or AWS WebUI.

## AWS account to deploy to

Local AWS credentials on machine where you run the scripts should match the account.
On laptop you set them with `aws configure`.

In Amazon cloud - assign IAM role with security groups in `config.sh` (see `Security groups` below).

## AWS account ID

See it in `My account` in AWS webUI.
Set it to `AWS_ACCOUNT_ID`.

## Task role

Add security group with permission to work with `AWS S3` into
[role that we use in ECS tasks](https://console.aws.amazon.com/iam/home#/roles/ecsTaskExecutionRole).

## Logs folder

Cluster use this log group:
- Name: /ecs/spark
- Retention: 2 weeks

If there is no such group in
[CloudWatch](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups)
you have to create it manually.

## Namespace for service discovery

You can list existed namespaces with `aws servicediscovery list-namespaces`

Set ID of the namespace to `$NAMESPACE_ID` and name to `$NAMESPACE_NAME`.

## Subnets & VPC

List all your subnets: `aws ec2 describe-subnets`.
We need one VPC with two subnets in different availability zones for high availability.

Set them to `$VPC_ID` and `$SUBNETS`.

## Security groups

You can see security groups with `aws ec2 describe-security-groups` or in
[AWS WebUI](https://console.aws.amazon.com/vpc/home?region=us-east-1#securityGroups)

### `$WORKER_SECURITY_GROUPS`

Should include groups that allow basic operation and all in/outbound traffic between the containers.

### `MASTER_SECURITY_GROUPS`

Should include groups that allow basic operation and security group that allows inbound traffic from other containers
to ports 8080 and 6066.

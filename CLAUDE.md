# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based Apache Spark standalone cluster with AWS services integration and RDKit for cheminformatics. The project provides a complete data science environment with PySpark, Pandas, and RDKit for chemical data processing.

## Development Commands

### Local Development
```bash
# Start the entire Spark cluster locally
./compose.sh up --build

# Stop the cluster
./compose.sh down

# View logs
./compose.sh logs -f [service-name]
```

### AWS ECS Deployment
```bash
# Push images to AWS ECR
ecs/push_images.sh

# Create and start Spark cluster in AWS ECS
ecs/create_cluster.sh

# Submit jobs to the cluster
ecs/submit.sh

# Clean up cluster and resources
ecs/delete_cluster.sh
```

## Architecture

### Docker Images Hierarchy
1. **andgineer/spark-aws** - Base Spark 3 + Hadoop 3 + AWS integration
2. **andgineer/spark-aws-conda** - Adds Anaconda with Pandas
3. **andgineer/spark-aws-rdkit** - Adds RDKit for cheminformatics

### Service Architecture
- **spark-master**: Spark driver/master node (ports 8080, 7077, 4040, 6066)
- **spark-worker**: Primary worker node (port 8081)  
- **spark-coworker**: Second worker node (port 8082)
- **submit**: Job submission container with example PySpark application

### Key Configuration
- All services use the `andgineer/spark-aws-rdkit` image
- User/group permissions handled via `USER_NAME:USER_GROUP` environment variables
- Source code mounted at `/python` in all containers
- Spark master URL: `spark://spark-master:7077` (internal) or `spark://localhost:7077` (external)

## File Structure

```
src/
├── health_check.py          # Example PySpark application for testing cluster connectivity

docker/
├── spark-aws-rdkit/         # RDKit-enabled Spark image
│   ├── Dockerfile
│   └── environment.yml      # Conda environment with RDKit
├── submit/                  # Job submission container
│   ├── Dockerfile
│   └── start.sh            # Waits for master, then runs health_check.py

ecs/                        # AWS ECS deployment scripts
├── dev/config.sh          # AWS configuration (needs customization)
└── README.md             # Detailed AWS deployment instructions
```

## AWS ECS Configuration

Before deploying to AWS, customize `ecs/dev/config.sh` with:
- AWS_ACCOUNT_ID
- VPC_ID and SUBNETS  
- Security groups (WORKER_SECURITY_GROUPS, MASTER_SECURITY_GROUPS)
- NAMESPACE_ID and NAMESPACE_NAME for service discovery

## Access Points

### Local Development
- Spark Web UI: http://localhost:8080
- Worker 1 UI: http://localhost:8081  
- Worker 2 UI: http://localhost:8082
- Spark Driver: spark://localhost:7077

### PySpark Connection
```python
from pyspark import SparkContext, SparkConf

conf = SparkConf()
conf.setMaster('spark://localhost:7077')  # Local
# conf.setMaster('spark://spark-master:7077')  # Docker internal
sc = SparkContext(conf=conf)
```

## Important Notes

- Linux users: Change `docker.for.mac.localhost` to `localhost` in environment variables
- The compose.sh script sets proper user group permissions for Docker volumes
- Health check example in src/health_check.py demonstrates basic Spark RDD operations
- AWS deployment uses Cloud Map for service discovery between master and workers
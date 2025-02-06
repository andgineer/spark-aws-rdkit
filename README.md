# Docker-based PySpark cluster with AWS services and RDKit

Docker-based Apache Spark standalone cluster with 
AWS services integration (S3, etc.) and comprehensive Data Science environment 
including PySpark, Pandas, and RDKit for cheminformatics.

## Features

- Apache Spark cluster in standalone mode
- Full AWS services compatibility (S3, etc.)
- Conda environment with Data Science tools:
  - PySpark
  - Pandas
  - RDKit for cheminformatics (https://www.rdkit.org) 
- Deployment options:
  - Local with `docker compose`
  - Cloud with AWS ECS

## Quick Start

Launch locally with `docker compose`:

```bash
./compose.sh up --build
```

This starts:
- Spark Master
- Two Spark Workers
- Example job container (`submit`)

Access points:
- Spark Web UI: http://localhost:8080
- Spark Driver: `spark://localhost:7077`
  - For PySpark use `setMaster('spark://localhost:7077')`

> Note: On Linux, change `docker.for.mac.localhost` to `localhost` in `.env` file.

## Example PySpark Application

The `submit` container demonstrates how to:
- Connect to the Spark cluster
- Submit Spark jobs
- Process data with PySpark

Check `src/` directory for the implementation details.

## AWS ECS Deployment

For production deployment on AWS Elastic Container Service (ECS):

1. Navigate to `ecs/` directory
2. Configure your deployment in `config.sh`
3. Run the automated deployment scripts

Detailed instructions available in `ecs/README.md`.

## Docker Images

Public Docker images available on Docker Hub, no need to build locally:

1. **[andgineer/spark-aws](https://hub.docker.com/r/andgineer/spark-aws)**
   - Base image with Spark 3 and Hadoop 3
   - AWS services integration

2. **[andgineer/spark-aws-conda](https://hub.docker.com/r/andgineer/spark-aws-conda)**
   - Extends base image
   - Adds Anaconda with Pandas

3. **[andgineer/spark-aws-rdkit](https://hub.docker.com/r/andgineer/spark-aws-rdkit)**
   - Adds RDKit for cheminformatics
   - Complete Data Science environment


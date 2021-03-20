# Apache Spark compatible with Amazon services for Data Science and Cheminformatics 

This is completely functional Spark Standalone cluster compatible with AWS services like S3.

You can launch it locally with `docker-compose` or in Amazon cloud `AWS ECS`.

## PySpark example

Separate container `submit` will wait for Spark cluster availability and after that it will
run PySpark example. The example shows how to submit Spark jobs to the cluster. 
For details see `src/`.

## Docker-compose

    ./compose.sh up --build
    
That will start Spark Master and two Workers, and example in `submit`.

Spark Web UI will be available on http://localhost:8080

Spark Driver on spark://localhost:7077
(PySpark: `setMaster('spark://localhost:7077')`).

Current settings are for Docker on MacOS. 
If you are on Linux change `docker.for.mac.localhost` in `.env` to `localhost`.

### Docker images
- [andgineer/spark-aws](https://hub.docker.com/repository/docker/andgineer/spark-aws):  Spark 3 and Hadoop 3 so you can access Amazon services from it.
- [andgineer/spark-aws-conda](https://hub.docker.com/repository/docker/andgineer/spark-aws-conda): adds on top of that Anaconda with Pandas.
- [andgineer/spark-aws-rdkit](https://hub.docker.com/repository/docker/andgineer/spark-aws-rdkit) : adds [RDKit](https://www.rdkit.org).

## AWS ECS

This Apache Spark containers also tested with AWS ECS (Amazon Container Orchestration Service).

See scripts and `README.md` in `ecs/`.

You fill configuration into `config.sh` and after that you can create Spark cluster in AWS ESC completely automatically.

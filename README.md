# Apache Spark compatible with Amazon services for Data Science and Cheminformatics 

This is completely functional Spark Standalone cluster.
 
## docker

Current settings is for Docker on MacOS. 
If you are on Linux change `docker.for.mac.localhost` in `.env` to `localhost`.

After that just

    ./compose.sh up --build
    
That will start Spark Master and two Workers.

Spark Web UI will be available on http://localhost:8080

[pyspark](https://realpython.com/pyspark-intro/) can access spark://localhost:7077 
(`setMaster('spark://localhost:7077')`).

There is example how to start Spark jobs, it starts automatically with the cluster and you will see the output. 
For detailes see `src/`.

This Spark installation is compatible with Amazon cloud. I installes all libs you need so you can use `boto3` and access
any AWS resources - just place your AWS credentials inside the container, or run it as Fargate task with appropriate IAM
role.

### Docker images
- [andgineer/spark-aws](https://hub.docker.com/repository/docker/andgineer/spark-aws):  Spark 3 and Hadoop 3 so you can access Amazon services from it.
- [andgineer/spark-aws-conda](https://hub.docker.com/repository/docker/andgineer/spark-aws-conda): adds on top of that Anaconda with Pandas.
- [andgineer/spark-aws-rdkit](https://hub.docker.com/repository/docker/andgineer/spark-aws-rdkit) : adds [RDKit](https://www.rdkit.org).

This will save your time to install it by yourself. It is really very time consuming enterprise.

For faster conda dependency install I use [mamba](https://github.com/mamba-org/mamba).

## AWS ECS

This Apache Spark containers also tested with AWS ESC (Amazon Container Orchestration Service).

See scripts and `README.md` in `aws/`.
You fill configuration into `environment.sh` and after that you can create Spark cluster in AWS ESC completely automatically.

# Apache Spark compatible with Amazon services for Data Science and Cheminformatics 

The main challenge to access resources like AWS S3 from Spark - version of Hadoop lib included into Spark.
Even Spark 3 is shipped with Hadoop 2 that is incompatible with AWS client.

Docker image [andgineer/spark-aws](https://hub.docker.com/repository/docker/andgineer/spark-aws) 
uses Spark 3 and Hadoop 3 so you can access Amazon services from it.

Docker image [andgineer/spark-aws-conda](https://hub.docker.com/repository/docker/andgineer/spark-aws-conda) 
adds on top of that Anaconda with Pandas.

Docker image [andgineer/spark-aws-rdkit](https://hub.docker.com/repository/docker/andgineer/spark-aws-rdkit) 
adds [RDKit](https://www.rdkit.org).

This will save your time to install it by yourself. It is really very time consuming enterprise.

To start Spark Standalone cluster with two workers locally just fire

    docker-compose up
    
Spark Web UI will be available on http://localhost:8080
Set Master in [pyspark](https://realpython.com/pyspark-intro/) to spark://localhost:7077

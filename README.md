# Apache Spark for Cheminformatics compatible with Amazon services

The main challenge to access resources like AWS S3 from Spark - version of Hadoop lib included into Spark.
Even Spark 3 is shipped with Hadoop 2 that is incompatible with AWS client.

Docker image `andgineed/spark-aws` uses Spark 3 and Hadoop 3 so you can access Amazon services from it.

Docker image `andgineed/spark-aws-rdkit` adds on top of that anaconda with RDKit installed.
This will save your time to install it by yourself.

And with this lib installed you can use RDKit from your pyspark jobs.

import pyspark
from pyspark import SparkContext

conf = pyspark.SparkConf()
conf.setMaster('spark://spark-master:7077')
sc = SparkContext(conf=conf)

big_list = range(10000)
rdd = sc.parallelize(big_list, 2)
odds = rdd.filter(lambda x: x % 2 != 0)
odds.take(5)

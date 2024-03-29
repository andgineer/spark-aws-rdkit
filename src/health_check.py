import pyspark
from pyspark import SparkContext
import sys


LOCAL_SPARK = 'local'
SHOW_RESULT_LENGTH = 5

conf = pyspark.SparkConf()
master_url = LOCAL_SPARK if len(sys.argv) <= 1 else sys.argv[1]
if master_url != LOCAL_SPARK:
    conf.setMaster(master_url)
sc = SparkContext(conf=conf)

big_list = range(10000)
rdd = sc.parallelize(big_list, 2)
odds = rdd.filter(lambda x: x % 2 != 0)

print(f">>>>> Calculation finished, {SHOW_RESULT_LENGTH} first odd numbers are {odds.take(SHOW_RESULT_LENGTH)}")

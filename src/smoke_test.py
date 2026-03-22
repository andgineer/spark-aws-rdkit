#!/usr/bin/env python3
"""
Smoke test for spark-aws-rdkit container.
Verifies PySpark (with Hadoop classpath), AWS (boto3), and RDKit are functional.
Run inside the container: python /python/smoke_test.py
"""
import sys


def test_imports():
    import boto3  # noqa: F401
    from rdkit import Chem  # noqa: F401
    print("OK imports: boto3, rdkit")


def test_pyspark_local():
    from pyspark import SparkContext, SparkConf

    conf = SparkConf().setMaster("local[2]").setAppName("smoke-test")
    sc = SparkContext(conf=conf)
    try:
        total = sc.parallelize(range(10)).sum()
        assert total == 45, f"Expected 45, got {total}"
        print(f"OK PySpark local mode: sum(0..9) = {total}")
    finally:
        sc.stop()


def test_rdkit_udf():
    from pyspark.sql import SparkSession
    from pyspark.sql.functions import udf
    from pyspark.sql.types import FloatType
    from rdkit import Chem
    from rdkit.Chem import Descriptors

    spark = SparkSession.builder \
        .master("local[2]") \
        .appName("smoke-test-rdkit") \
        .getOrCreate()
    try:
        smiles = ["c1ccccc1", "CC(=O)O", "CCO"]
        df = spark.createDataFrame([(s,) for s in smiles], ["smiles"])

        @udf(FloatType())
        def mol_weight(smi):
            mol = Chem.MolFromSmiles(smi)
            return float(Descriptors.MolWt(mol)) if mol else None

        rows = df.withColumn("mw", mol_weight("smiles")).collect()
        assert len(rows) == 3
        assert all(r.mw is not None for r in rows)
        print(f"OK RDKit UDF in PySpark: {[(r.smiles, round(r.mw, 1)) for r in rows]}")
    finally:
        spark.stop()


if __name__ == "__main__":
    print("Running smoke tests...")
    try:
        test_imports()
        test_pyspark_local()
        test_rdkit_udf()
    except Exception as e:
        print(f"FAILED: {e}", file=sys.stderr)
        sys.exit(1)
    print("All smoke tests passed.")

#!/usr/bin/env bash

REST_SERVER="localhost:6066"
echo "Send job to Spark cluster by REST API at ${REST_SERVER}"
echo "\n(!) Please check that the REST service is enabled"
echo "- set spark.master.rest.enabled in Spark config\n"

curl -X POST http://${REST_SERVER}/v1/submissions/create \
  --header "Content-Type:application/json;charset=UTF-8" \
  --data '{
    "action" : "CreateSubmissionRequest",
    "appResource": "file:/python/health_check.py",
    "appArgs" : [ "/python/health_check.py" ],
    "clientSparkVersion" : "3.0.2",
    "environmentVariables" : {
      "SPARK_ENV_LOADED" : "1"
    },
    "mainClass":"org.apache.spark.deploy.SparkSubmit",
    "sparkProperties" : {
        "spark.driver.supervise" : "true",
        "spark.app.name" : "Health check REST",
        "spark.eventLog.enabled": "false",
        "spark.submit.deployMode" : "client",
        "spark.master" : "spark://spark-master.???:6066"
  }
}'

#Reply
#{
#  "action" : "CreateSubmissionResponse",
#  "message" : "Driver successfully submitted as driver-20210312164947-0001",
#  "serverSparkVersion" : "3.0.2",
#  "submissionId" : "driver-20210312164947-0001",
#  "success" : true
#}%

# Get status
#curl http://192.168.1.1:6066/v1/submissions/status/driver-20200923223841-0001

# Kill job
# curl -X POST http://192.168.1.1:6066/v1/submissions/kill/driver-20200923223841-0001

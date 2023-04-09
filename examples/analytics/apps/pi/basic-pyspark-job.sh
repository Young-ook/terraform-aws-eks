#!/bin/bash

### envs
EMR_VIRTUAL_CLUSTER_ID=''
EMR_JOB_EXECUTION_ROLE_ARN=''
JOB_NAME='pi'
EMR_EKS_RELEASE_LABEL='emr-6.8.0-latest'

function print_usage() {
  echo "Usage: $0 -c(cluster) <emr-cluster-id> -r(role) <emr-job-execution-role-arn>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":c:r:" opt; do
    case $opt in
      c) EMR_VIRTUAL_CLUSTER_ID="$OPTARG"
      ;;
      r) EMR_JOB_EXECUTION_ROLE_ARN="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function run_job() {
  EMR_VIRTUAL_CLUSTER_NAME=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?id=='${EMR_EMR_VIRTUAL_CLUSTER_ID}' && state=='RUNNING'].name" --output text)

  # Execute Spark job
  if [[ $EMR_VIRTUAL_CLUSTER_ID != "" ]]; then
    echo "Found Cluster $EMR_VIRTUAL_CLUSTER_NAME; Executing the Spark job now..."
    aws emr-containers start-job-run \
      --virtual-cluster-id $EMR_VIRTUAL_CLUSTER_ID \
      --name $JOB_NAME \
      --execution-role-arn $EMR_JOB_EXECUTION_ROLE_ARN \
      --release-label $EMR_EKS_RELEASE_LABEL \
      --job-driver '{
        "sparkSubmitJobDriver": {
          "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
          "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
        }
      }'
  else
    echo "Cluster is not in running state $EMR_VIRTUAL_CLUSTER_NAME"
  fi
}

### main
process_args "$@"
run_job

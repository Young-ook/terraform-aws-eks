#!/bin/bash
set -e

EKS_NAME=eks
NAMESPACE=default

export AWS_REGION=us-east-1

function print_usage() {
  echo "Usage: $0 -c(cluster) <cluster-name> -r(region) <aws-region> -n(namespace) <namespace>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":c:n:r:" opt; do
    case $opt in
      c) EKS_NAME="$OPTARG"
      ;;
      r) AWS_REGION="$OPTARG"
      ;;
      n) NAMESPACE="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function delete() {
  ### delete all ebs volumes
  volumes=$(aws ec2 describe-volumes \
    --filters \
      Name=tag:kubernetes.io/created-for/pvc/namespace,Values=$NAMESPACE \
      Name=tag:KubernetesCluster,Values=$EKS_NAME \
    --query "Volumes[*].{ID:VolumeId}" \
    --region $AWS_REGION \
    --output text)

  for volume in $volumes
  do
    aws ec2 delete-volume --volume-id $volume --region $AWS_REGION
  done
}

# main
process_args "$@"
delete

unset AWS_REGION

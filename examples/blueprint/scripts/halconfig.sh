#!/bin/bash
# configure spinnaker
set -e

CURDIR=`dirname $0`
HAL_EXEC="kubectl -n spinnaker exec -it cd-spinnaker-halyard-0 --"
SPIN_VER="1.30"

export AWS_REGION=us-east-1
export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path> -a(account) <aws-account-id> -r(region) <aws-region> -s(spinnaker-managed-role) <role-name> -v(version) <spinnaker-version>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":a:r:k:s:v:" opt; do
    case $opt in
      a) AWS_ID="$OPTARG"
      ;;
      r) AWS_REGION="$OPTARG"
      ;;
      k) KUBECONFIG="$OPTARG"
      ;;
      s) SPIN_MANAGED_ROLE="$OPTARG"
      ;;
      v) SPIN_VER="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function setup() {
  if [ ! -e $KUBECONFIG ]; then
    echo "Can't find $KUBECONFIG"
    exit -1
  fi

  ### configure a build provider and an artifact repository
  $HAL_EXEC hal config ci codebuild account add platform \
    --region $AWS_REGION \
    --account-id $AWS_ID \
    --assume-role $SPIN_MANAGED_ROLE
  $HAL_EXEC hal config ci codebuild enable

  $HAL_EXEC hal config artifact s3 account add platform \
    --region $AWS_REGION
  $HAL_EXEC hal config artifact s3 enable

  $HAL_EXEC hal config version edit --version $SPIN_VER
  $HAL_EXEC hal deploy apply
}

# main
process_args "$@"
setup

unset AWS_REGION
unset KUBECONFIG

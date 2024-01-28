#!/bin/bash
# interactive halyard cli for spinnaker management
set -e

CURDIR=`dirname $0`
PODNAME=spinnaker-halyard-0

export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path> -p(pod) <halyard-pod-name>"
}

function process_args() {
  while getopts ":k:p:" opt; do
    case $opt in
      k) KUBECONFIG="$OPTARG"
      ;;
      p) PODNAME="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
        print_usage
        exit -1
      ;;
    esac
  done
}

function validate() {
  if [ ! -e $KUBECONFIG ]; then
    echo "Can't find $KUBECONFIG"
    exit -1
  fi
}

function halconfig() {
  ### configure a build provider and an artifact repository
  HAL_EXEC="kubectl -n spinnaker exec -it spinnaker-halyard-0 --"

  $HAL_EXEC hal config ci codebuild account add platform \
    --region ${aws_region} \
    --account-id ${aws_id} \
    --assume-role ${spin_managed_role}
  $HAL_EXEC hal config ci codebuild enable

  $HAL_EXEC hal config artifact s3 account add platform \
    --region ${aws_region}
  $HAL_EXEC hal config artifact s3 enable

  $HAL_EXEC hal deploy apply
}

function irsa() {
  ### configure IRSA annotation
  ${spin_irsa_cli}
}

function prompt() {
  kubectl -n spinnaker exec -it $PODNAME -- bash
}

# main
process_args "$@"
validate
irsa
prompt

unset KUBECONFIG

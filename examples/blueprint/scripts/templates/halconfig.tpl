#!/bin/bash
# configure spinnaker
set -e

CURDIR=`dirname $0`
export KUBECONFIG=$CURDIR/kubeconfig

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

# main
validate
halconfig
irsa

unset KUBECONFIG

#!/bin/bash
# download the kubeflow manifests
set -e

CURDIR=`dirname $0`

export KUBEFLOW_RELEASE_VERSION=v1.6.1
export AWS_RELEASE_VERSION=v1.6.1-aws-b1.0.0

function print_usage() {
  echo "Usage: $0 -k <kubeflow-release-version> -a <aws-release-version>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":a:k:" opt; do
    case $opt in
      a) AWS_RELEASE_VERSION="$OPTARG"
      ;;
      k) KUBEFLOW_RELEASE_VERSION="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function clone() {
  # clean up the existing directory
  if [ -e kubeflow-manifests ]; then
    rm -rf kubeflow-manifests
  fi

  # clone the awslabs/kubeflow-manifests
  git clone https://github.com/awslabs/kubeflow-manifests.git && cd kubeflow-manifests
  git checkout $AWS_RELEASE_VERSION
  git clone --branch $KUBEFLOW_RELEASE_VERSION https://github.com/kubeflow/manifests.git upstream && cd -
}

# main
process_args "$@"
clone

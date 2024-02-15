#!/bin/bash
# purge the resources created by kubeflow
set -e

CURDIR=`dirname $0`
export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":k:" opt; do
    case $opt in
      k) KUBECONFIG="$OPTARG"
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

function purge() {
  ### stop the curretly running processes
  namespaces="auth istio-system knative-serving knative-eventing kubeflow kubeflow-user-example-com"
  for namespace in $namespaces
  do
    kubectl -n $namespace delete pod --all --force
  done
}

# main
process_args "$@"
validate
purge

unset KUBECONFIG

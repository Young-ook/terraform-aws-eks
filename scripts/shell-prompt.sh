#!/bin/bash
# access to shell interactive mode

### interactive shell examples
### - halyard: kubectl -n spinnaker exec -it halyard-0 -- bash

set -e

CURDIR=`dirname $0`
NS=default
POD=default
SH=bash

export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path> -n(namespace) <namespace> -p(pod) <pod>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":k:n:p:" opt; do
    case $opt in
      k) KUBECONFIG="$OPTARG"
      ;;
      n) NS="$OPTARG"
      ;;
      p) POD="$OPTARG"
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

function prompt() {
  kubectl -n $NS exec -it $POD -- $SH
}

# main
process_args "$@"
validate
prompt

unset KUBECONFIG

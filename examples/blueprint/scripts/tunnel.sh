#!/bin/bash
# establish ssh tunnel to access the spinnaker
set -e

CURDIR=`dirname $0`
NS=default
SVC=service
LPORT=8080
RPORT=8080

export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path> -s(service) <service-name> -n(namespace) <namespace> -l(local-port) <port> -p(port) <port>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":k:n:s:l:p:" opt; do
    case $opt in
      k) KUBECONFIG="$OPTARG"
      ;;
      n) NS="$OPTARG"
      ;;
      s) SVC="$OPTARG"
      ;;
      l) LPORT="$OPTARG"
      ;;
      p) RPORT="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function conn() {
  if [ ! -e $KUBECONFIG ]; then
    echo "Can't find $KUBECONFIG"
    exit -1
  fi

### kubernetes port forwarding examples
###
### spinnaker: kubernetes -n spinnaker port-forward svc/spin-deck 8080:9000
### chaos-mesh: kubernetes -n chaos-mesh port-forward svc/chaos-dashboard 2333:2333

  kubectl -n $NS port-forward svc/$SVC ${LPORT}:${RPORT}
}

# main
process_args "$@"
conn

unset KUBECONFIG

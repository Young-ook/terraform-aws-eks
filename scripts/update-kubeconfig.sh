#!/bin/bash
# update/generate kubernetes config file to access eks cluster
set -e

CURDIR=`dirname $0`
EKS_NAME=eks
SPINNAKER_MANAGED=false

export AWS_REGION=us-east-1
export KUBECONFIG=$CURDIR/kubeconfig

function print_usage() {
  echo "Usage: $0 -k <kubeconfig-path> -n(name) <eks-name> -r(region) <aws-region> -s(spinnaker-managed) <true|false>"
}

function process_args() {
  if [[ $# < 1 ]]; then
    print_usage
    exit -1
  fi

  while getopts ":n:a:r:k:s:" opt; do
    case $opt in
      n) EKS_NAME="$OPTARG"
      ;;
      r) AWS_REGION="$OPTARG"
      ;;
      k) KUBECONFIG="$OPTARG"
      ;;
      s) SPINNAKER_MANAGED="$OPTARG"
      ;;
      \?)
        >&2 echo "Unrecognized argument '$OPTARG'"
      ;;
    esac
  done
}

function init() {
  if [ -e $KUBECONFIG ]; then
    rm $KUBECONFIG
  fi

  # update kubeconfig
  aws eks update-kubeconfig --name $EKS_NAME --region $AWS_REGION

  if [ $SPINNAKER_MANAGED = "true" ]; then
    local namespace=$EKS_NAME
    local serviceaccount=spinnaker-managed

    rbac $namespace $serviceaccount
    minify $namespace
  fi

  # restrict access
  chmod 600 $KUBECONFIG
}

function rbac() {
  local namespace=$1
  local serviceaccount=$2

cat  << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $namespace
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $serviceaccount
  namespace: $namespace
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $serviceaccount
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: $serviceaccount
  namespace: $namespace
EOF

  token=$(kubectl get secret \
     $(kubectl get serviceaccount $serviceaccount \
       -n $namespace \
       -o jsonpath='{.secrets[0].name}') \
    -n $namespace \
    -o jsonpath='{.data.token}' | base64 --decode)
  kubectl config set-credentials $serviceaccount --token=$token
  kubectl config set-context $namespace \
    --cluster=$(kubectl config current-context) \
    --user=$serviceaccount \
    --namespace=$namespace
}

function minify () {
  local context=$1

  kubectl config view --raw > $KUBECONFIG.full.tmp
  kubectl --kubeconfig $KUBECONFIG.full.tmp config use-context $context
  kubectl --kubeconfig $KUBECONFIG.full.tmp \
    config view --flatten --minify > $KUBECONFIG

  rm $KUBECONFIG.full.tmp
}

# main
process_args "$@"
init

unset AWS_REGION
unset KUBECONFIG

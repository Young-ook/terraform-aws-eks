#!/bin/bash

export WORK_DIR=$${PWD}

export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_aws.v1.0.1.yaml"
export CONFIG_FILE=$WORK_DIR/kfctl_aws.yaml

curl -o kfctl_aws.yaml $CONFIG_URI

yq '.spec.plugins[0].spec.enablePodIamPolicy = true' -i $CONFIG_FILE
yq '.spec.plugins[0].spec.region = "${aws_region}"' -i $CONFIG_FILE
yq '.spec.plugins[0].spec.roles[0] = "${eks_role}"' -i $CONFIG_FILE
sed -i -e 's/kubeflow-aws/'"${eks_role}"'/' $CONFIG_FILE

kfctl apply -V -f $CONFIG_FILE

unset CONFIG_FILE
unset CONFIG_URI
unset WORK_DIR

#!/bin/bash

export WORK_DIR=$${PWD}

export CONFIG_FILE=$WORK_DIR/kfctl_aws.yaml

kfctl delete -V -f $CONFIG_FILE

unset CONFIG_FILE
unset WORK_DIR

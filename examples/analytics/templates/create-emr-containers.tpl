#!/bin/bash
OUTPUT='.emr_cli_result'

aws emr-containers create-virtual-cluster --region "${aws_region}" --output text \
  --cli-input-json file://create-emr-virtual-cluster-request.json \
  --query 'id' 2>&1 | tee -a $${OUTPUT}

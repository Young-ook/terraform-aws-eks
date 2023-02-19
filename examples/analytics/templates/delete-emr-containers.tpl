#!/bin/bash
OUTPUT='.emr_cli_result'

while read id; do
  aws emr-containers delete-virtual-cluster --region "${aws_region}" --output text --id $${id}
done < $${OUTPUT}
rm $${OUTPUT}

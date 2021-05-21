{
    "tags": {
        "Name": "TerminateEC2InstancesWithFilters"
    },
    "description": "Terminate all instances with the tag env=prod in the specified VPC",
    "targets": {
        "ec2-instances": {
            "resourceType": "aws:ec2:instance",
            "resourceTags": {
                "env": "prod",
                "Name": "${asg}"
            },
            "filters": [
                {
                    "path": "Placement.AvailabilityZone",
                    "values": ["${az}"]
                },
                {
                    "path": "State.Name",
                    "values": ["running"]
                },
                {
                    "path": "VpcId",
                    "values": [ "${vpc}"]
                }
            ],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "TerminateInstances": {
            "actionId": "aws:ec2:terminate-instances",
            "description": "terminate the instances",
            "targets": {
                "Instances": "ec2-instances"
            }
        }
    },
    "stopConditions": [
        {
            "source": "aws:cloudwatch:alarm",
            "value": "${alarm}"
        }
    ],
    "roleArn": "${role}"
}

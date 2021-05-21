{
    "tags": {
        "Name": "CPUStress"
    },
    "description": "Run a CPU fault injection on the specified instance",
    "targets": {
        "ec2-instances": {
            "resourceType": "aws:ec2:instance",
            "resourceTags": {
                "env": "prod",
                "Name": "${asg}"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": ["running"]
                }
            ],
            "selectionMode": "PERCENT(50)"
        }
    },
    "actions": {
        "CPUStress": {
            "actionId": "aws:ssm:send-command",
            "description": "run cpu stress using ssm",
            "parameters": {
                "duration": "PT10M",
                "documentArn": "arn:aws:ssm:${region}::document/AWSFIS-Run-CPU-Stress",
                "documentParameters": "{\"DurationSeconds\": \"600\", \"InstallDependencies\": \"True\", \"CPU\": \"0\"}"
            },
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

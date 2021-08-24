{
    "tags": {
        "Name": "DiskStress"
    },
    "description": "Run a Disk fault injection on the specified instance",
    "targets": {
        "ec2-instances": {
            "resourceType": "aws:ec2:instance",
            "resourceTags": {
                "env": "prod"
            },
            "filters": [
                {
                    "path": "State.Name",
                    "values": ["running"]
                }
            ],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "DiskStress": {
            "actionId": "aws:ssm:send-command",
            "description": "run disk stress using ssm",
            "parameters": {
                "duration": "PT1M",
                "documentArn": "${doc_arn}",
                "documentParameters": "{\"DurationSeconds\": \"60\", \"Workers\": \"4\", \"Bytes\": \"15\", \"InstallDependencies\": \"True\"}"
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

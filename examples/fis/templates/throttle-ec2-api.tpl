{
    "tags": {
        "Name": "ThrottleEC2APIs"
    },
    "description": "Throttle the specified EC2 API actions on the specified IAM role",
    "targets": {
        "ec2-role": {
            "resourceType": "aws:iam:role",
            "resourceArns": ["${asg_role}"],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "ThrottleAPI": {
            "actionId": "aws:fis:inject-api-throttle-error",
            "description": "Throttle APIs for 5 minutes",
            "parameters": {
                "service": "ec2",
                "operations": "DescribeInstances,DescribeVolumes",
                "percentage": "100",
                "duration": "PT2M"
            },
            "targets": {
                "Roles": "ec2-role"
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

{
    "tags": {
        "Name": "TerminateEKSNodes"
    },
    "description": "Terminate all EKS nodes with the tag env=prod",
    "targets": {
        "eks-nodes": {
            "resourceType": "aws:eks:nodegroup",
            "resourceTags": {
                "env": "prod"
            },
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "TerminateInstances": {
            "actionId": "aws:eks:terminate-nodegroup-instances",
            "description": "terminate the node instances",
            "parameters": {
                "instanceTerminationPercentage": "30"
            },
            "targets": {
                "Nodegroups": "eks-nodes"
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

{
    "tags": {
        "Name": "TerminateEKSNodes"
    },
    "description": "Terminate EKS nodes",
    "targets": {
        "eks-nodes": {
            "resourceType": "aws:eks:nodegroup",
            "resourceArns": [
                "${nodegroup}"
            ],
            "selectionMode": "ALL"
        }
    },
    "actions": {
        "TerminateInstances": {
            "actionId": "aws:eks:terminate-nodegroup-instances",
            "description": "terminate the node instances",
            "parameters": {
                "instanceTerminationPercentage": "40"
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

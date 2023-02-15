{
    "name": "${emr_name}",
    "containerProvider": {
        "type": "EKS",
        "id": "${eks_name}",
        "info": {
            "eksInfo": {
                "namespace": "default"
            }
        }
    }
}

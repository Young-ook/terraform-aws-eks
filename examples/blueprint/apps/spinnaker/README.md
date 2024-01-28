[[English](README.md)] [[한국어](README.ko.md)]

# Spinnaker
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to build and install spinnaker on AWS. This module will create Amazon EKS, Amazon Aurora, Amazon S3 resources for spinnaker and utilise Helm chart to install spinnaker application on kubernetes. And it will also create a VPC to place an EKS and an Aurora cluster for the spinnaker. If you want to know how to use this module, please check below examples for more details.

## Install
To access Halyard, run the script to setup a interactive console in the examples/blueprint directory:
```
bash ./modules/kubernetes-addons/scripts/halconfig.sh -k kubeconfig -p spinnaker-halyard-0
```

Spinnaker version:
```
hal config version edit --version 1.33.0
```

Persistent storage:
```
echo spinnakeradmin | hal config storage s3 edit \
    --endpoint http://spinnaker-minio:9000 \
    --access-key-id spinnakeradmin \
    --secret-access-key --bucket spinnaker \
    --path-style-access true
hal config storage edit --type s3
```

Use deck (UI) as proxy to route to gate (API):
```
hal config security api edit --no-validate --override-base-url /gate
```


Kubernetes providers:
```
hal config provider kubernetes enable
hal config provider kubernetes account add default \
    --context default --service-account true \
    --omit-namespaces=kube-system,kube-public,spinnaker \
    --provider-version v2
```

Spinnaker deployment type:
```
hal config deploy edit --account-name default --type distributed \
    --location spinnaker
```

Deploy:
```
hal deploy apply
```

(Optional) AWS CodeBuild integration:
```
hal config ci codebuild account add platform \
    --region {{ AWS_REGION }} \
    --account-id {{ AWS_ACCOUNT_ID }} \
    --assume-role {{ SPINNAKER_ASSUMABLE_ROLE }}
hal config ci codebuild enable
```
(Optional) Enable an artifact repository:
```
hal config features edit --artifacts true
hal config artifact s3 account add platform --region {{ AWS_REGION }}
hal config artifact s3 enable
```

After configuration change, you must redeploy your spinnaker to apply the changes:
```
hal deploy apply
```

## Clean up
To destroy all spinnaker microservices, run halyard comment:
```
hal deploy clean
```

# Additional Resources
## Terraform Modules
- [Terraform module: Spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker)

---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ${eks_name}
  region: ${aws_region}
iamIdentityMappings:
  - serviceName: emr-containers
    namespace: ${namespace} # serviceName requires namespace

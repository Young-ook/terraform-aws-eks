### helm-addons
module "base" {
  source  = "Young-ook/eks/aws//modules/helm-addons"
  version = "2.0.3"
  tags    = merge(var.tags, local.default-tags)
  addons = [
    {
      ### for more details, https://cert-manager.io/docs/installation/helm/
      repository       = "https://charts.jetstack.io"
      name             = "cert-manager"
      chart_name       = "cert-manager"
      version          = "v1.10.0"
      namespace        = "cert-manager"
      create_namespace = true
      values = {
        "installCRDs" = "true"
      }
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "kubeflow-namespace"
      chart_name       = "kubeflow-namespace"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "istio"
      chart_name       = "istio-1-14"
      create_namespace = false
    },
  ]
}

module "utils" {
  depends_on = [module.base]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.3"
  tags       = merge(var.tags, local.default-tags)
  addons = [
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "dex"
      chart_name       = "dex"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "oidc-authservice"
      chart_name       = "oidc-authservice"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "profiles-and-kfam"
      chart_name       = "profiles-and-kfam"
      create_namespace = false
    },

/*
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "issure"
      chart_name       = "kubeflow-issuer"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "admission-webhook"
      chart_name       = "admission-webhook"
      create_namespace = false
    },
*/
  ]
}

module "apps" {
  depends_on = [module.utils]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.3"
  tags       = merge(var.tags, local.default-tags)
  addons = [
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "knative-eventing"
      chart_name       = "knative-eventing"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "knative-serving"
      chart_name       = "knative-serving"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "kserve"
      chart_name       = "kserve"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "cluster-local-gateway"
      chart_name       = "cluster-local-gateway"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "kubeflow-istio-resources"
      chart_name       = "kubeflow-istio-resources"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "kubeflow-roles"
      chart_name       = "kubeflow-roles"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "central-dashboard"
      chart_name       = "central-dashboard"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps", "kubeflow-pipelines"])
      name             = "kubeflow-pipelines"
      chart_name       = "vanilla"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps", "katib"])
      name             = "katib"
      chart_name       = "vanilla"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "notebook-controller"
      chart_name       = "notebook-controller"
      create_namespace = false
      values = {
        "cullingPolicy.enableCulling"       = false
        "cullingPolicy.cullIdleTime"        = 30
        "cullingPolicy.idlenessCheckPeriod" = 5
      }
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "jupyter-web-app"
      chart_name       = "jupyter-web-app"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "models-web-app"
      chart_name       = "models-web-app"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "volumes-web-app"
      chart_name       = "volumes-web-app"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "tensorboards-web-app"
      chart_name       = "tensorboards-web-app"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "tensorboard-controller"
      chart_name       = "tensorboard-controller"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "apps"])
      name             = "training-operator"
      chart_name       = "training-operator"
      create_namespace = false
    },
    {
      repository       = join("/", [var.kubeflow_helm_repo, "common"])
      name             = "user-namespace"
      chart_name       = "user-namespace"
      create_namespace = false
    },
  ]
}

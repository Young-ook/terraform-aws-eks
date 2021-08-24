[settings.kubernetes]
cluster-name = "${cluster_name}"
api-server = "${cluster_endpoint}"
cluster-certificate = "${cluster_ca_data}"

[settings.host-containers.admin]
enabled = ${admin_container_enabled}
superpowered = ${admin_container_superpowered}
%{ if admin_container_source != "" }
source = "${admin_container_source}"
%{ endif }

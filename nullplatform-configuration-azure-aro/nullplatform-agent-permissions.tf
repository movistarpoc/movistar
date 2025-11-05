# Configure nullplatform namespace labels for pod security
resource "kubernetes_labels" "nullplatform_namespace_labels" {
  api_version = "v1"
  kind        = "Namespace"
  force       = true

  metadata {
    name = "nullplatform"
  }

  labels = {
    "pod-security.kubernetes.io/warn"  = "baseline"
    "pod-security.kubernetes.io/audit" = "baseline"
  }

  depends_on = [helm_release.nullplatform_agent]
}

# Add anyuid SCC to default service account in nullplatform namespace
resource "kubernetes_manifest" "nullplatform_anyuid_scc" {
  manifest = {
    apiVersion = "security.openshift.io/v1"
    kind       = "SecurityContextConstraints"
    metadata = {
      name = "nullplatform-anyuid-scc"
    }
    allowHostDirVolumePlugin  = false
    allowHostPorts            = false
    allowHostNetwork          = false
    allowPrivilegedContainer  = false
    allowPrivilegeEscalation  = true
    allowedCapabilities       = []
    defaultAddCapabilities    = []
    priority                  = null
    readOnlyRootFilesystem    = false
    requiredDropCapabilities  = ["MKNOD"]

    runAsUser = {
      type = "RunAsAny"
    }

    seLinuxContext = {
      type = "MustRunAs"
    }

    fsGroup = {
      type = "RunAsAny"
    }

    supplementalGroups = {
      type = "RunAsAny"
    }

    volumes = [
      "configMap",
      "downwardAPI",
      "emptyDir",
      "persistentVolumeClaim",
      "projected",
      "secret"
    ]

    users = [
      "system:serviceaccount:nullplatform:default"
    ]
    groups = []
  }

  depends_on = [helm_release.nullplatform_agent]
}

# Grant Private DNS Zone Contributor role to agent service principal
resource "azurerm_role_assignment" "agent_private_dns_permissions" {
  scope                = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${var.private_dns_azure_resource_group_name}/providers/Microsoft.Network/privateDnsZones/${var.private_scope_domain_name}"
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = var.azure_service_principal_object_id
}

# This SCC is now managed by the nullplatform-base helm chart (version 2.21.0+)
# Commented out to avoid conflicts with Helm ownership
resource "kubernetes_manifest" "nullplatform_scc" {
  manifest = {
    apiVersion = "security.openshift.io/v1"
    kind       = "SecurityContextConstraints"
    metadata = {
      name = "nullplatform-scc"
    }
    allowHostDirVolumePlugin  = true
    allowHostPorts            = true
    allowHostNetwork          = false
    allowPrivilegedContainer  = false
    allowedCapabilities       = []
    defaultAddCapabilities    = []
    priority                  = null
    readOnlyRootFilesystem    = false
    requiredDropCapabilities  = []

    runAsUser = {
      type = "RunAsAny"
    }

    seLinuxContext = {
      type = "RunAsAny"
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
      "hostPath",
      "persistentVolumeClaim",
      "projected",
      "secret"
    ]

    users = [
      "system:serviceaccount:nullplatform-tools:nullplatform-pod-metadata-reader-sa"
    ]
    groups = []
  }
}
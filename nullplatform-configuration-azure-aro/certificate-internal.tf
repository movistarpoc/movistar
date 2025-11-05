# Create ClusterIssuer for internal domain
resource "kubernetes_manifest" "letsencrypt_internal_clusterissuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-internal"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "it@nullplatform.io"
        privateKeySecretRef = {
          name = "letsencrypt-internal"
        }
        solvers = [
          {
            dns01 = {
              azureDNS = {
                clientID = var.azure_client_id
                clientSecretSecretRef = {
                  name = "azuredns-config"
                  key  = "client-secret"
                }
                subscriptionID    = var.azure_subscription_id
                tenantID          = var.azure_tenant_id
                resourceGroupName = var.private_dns_azure_resource_group_name
                hostedZoneName    = var.private_scope_domain_name
                environment       = "AzurePublicCloud"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [module.nullplatform_aro_cert_manager_chart]
}

# Create Certificate for internal wildcard domain
resource "kubernetes_manifest" "wildcard_tls_internal_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-tls-internal"
      namespace = "openshift-ingress"
    }
    spec = {
      secretName = "wildcard-tls-internal"
      issuerRef = {
        name = "letsencrypt-internal"
        kind = "ClusterIssuer"
      }
      commonName = "*.${var.private_scope_domain_name}"
      dnsNames = [
        var.private_scope_domain_name,
        "*.${var.private_scope_domain_name}"
      ]
    }
  }

  depends_on = [kubernetes_manifest.letsencrypt_internal_clusterissuer]
}
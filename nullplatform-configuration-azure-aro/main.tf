###############################################################################
# Code Repository
################################################################################
module "nullplatform_code_repository" {
  source                      = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/code_repository?ref=v1.4.0"
  np_api_key                  = var.account_level_np_api_key
  nrn                         = var.account_level_nrn
  git_provider                = "gitlab"
  gitlab_group_path           = var.gitlab_group_path
  gitlab_access_token         = var.gitlab_access_token
  gitlab_installation_url     = var.gitlab_installation_url
  gitlab_repository_prefix    = var.gitlab_repository_prefix
  gitlab_slug                 = var.gitlab_slug
  gitlab_collaborators_config = var.gitlab_collaborators_config

}
###############################################################################
# Cloud Providers Config
################################################################################
module "nullplatform_cloud_provider" {
  source                            = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/cloud/azure/cloud?ref=feature/aro"
  nrn                               = var.account_level_nrn
  application_domain                = var.application_domain
  np_api_key                        = var.account_level_np_api_key
  domain_name                       = var.domain_name
  dimensions                        = var.dimensions
  azure_resource_group_name         = var.public_dns_azure_resource_group_name
  azure_tenant_id                   = var.azure_tenant_id
  azure_subscription_id             = var.azure_subscription_id
  private_domain_name               = var.private_scope_domain_name
  private_dns_resource_group_name   = coalesce(var.private_dns_azure_resource_group_name, var.azure_resource_group_name)
}

###############################################################################
# Asset Repository
################################################################################
module "nullplatform_asset_repository" {
  source       = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/asset/docker_server?ref=v1.4.0"
  nrn          = var.account_level_nrn
  np_api_key   = var.account_level_np_api_key
  login_server = var.login_server
  username     = var.username
  password     = var.password
  path         = var.path
}

###############################################################################
# Dimensions
################################################################################
module "nullplatform_dimension" {
  source       = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/dimensions?ref=v1.4.0"
  np_api_key   = var.account_level_np_api_key
  nrn          = var.account_level_nrn
  environments = var.environments
}

###############################################################################
# Nullplatform Base
################################################################################
module "nullplatform_aro_cluster_base_chart" {
  source                         = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/base?ref=feature/aro"
  np_api_key                     = var.account_level_np_api_key
  nrn                            = var.account_level_nrn
  cloud_provider                 = "aro"

  nullplatform_base_helm_version = local.nullplatform_base_helm_version
  #  exporter_prometheus_port       = var.exporter_prometheus_port
  ingressControllers = {
    public = {
      name    = "internet-facing"
      enabled = true
      scope   = "External"
      domain  = "poc-movistar.nullapps.io"
    }
    private = {
      name    = "internal"
      enabled = true
      scope   = "Internal"
      domain  = "poc-movistar-internal.nullapps.io"
    }
  }
}

###############################################################################
# ARO Cluster: TLS certificate management (installs cert manager and issuer)
################################################################################
module "nullplatform_aro_cert_manager_chart" {
  source                       = "git::https://github.com/nullplatform/tofu-modules.git///infrastructure/commons/cert_manager?ref=feature/aro"
  cert_manager_config_version  = local.nullplatform_base_helm_version
  namespacecontroller_name    = "openshift-ingress"
  hosted_zone_name            = var.public_scope_domain_name
  azure_enabled               = true
  azure_subscription_id       = var.azure_subscription_id
  azure_resource_group_name   = var.public_dns_azure_resource_group_name
  azure_client_id             = var.azure_client_id
  azure_client_secret         = var.azure_client_secret
  azure_tenant_id             = var.azure_tenant_id
  azure_hosted_zone_name      = var.public_scope_domain_name

  # Uncomment to change default K8s namespace (cert-manager)
  # namespace                    = var.cert_manager_namespace

  # Uncomment to change default
  # cert_manager_version         = var.cert_manager_version
}

## ARO requires you to have different TLS certs for each ingress because domains have to differ
## The internal certificate is created manually via kubectl (see wildcard-tls-internal.yaml)

###############################################################################
# Resource group | Change when the TF is handed over to you
###############################################################################
# module "resource_group" {
#   source              = "git::https://github.com/nullplatform/tofu-modules.git///infrastructure/azure/resource_group?ref=v1.4.0"
#   name                = var.domain_name
#   resource_group_name = var.azure_resource_group_name
# }

###############################################################################
# DNS | Change when the TF is handed over to you
###############################################################################
# module "dns" {
#   source              = "git::https://github.com/nullplatform/tofu-modules.git///infrastructure/azure/dns?ref=v1.4.0"
#   name                = var.domain_name
#   resource_group_name = var.azure_resource_group_name
# }

###############################################################################
# TODO: Private DNS
###############################################################################

###############################################################################
# Agent | At least one per cluster
################################################################################

locals {
  # Create artificial dependency chain
  # This forces Terraform to wait for the agent and prerequisite modules to complete
  agent_ready = alltrue([
    module.nullplatform_code_repository != null,
    module.nullplatform_cloud_provider != null,
    module.nullplatform_asset_repository != null,
    module.nullplatform_dimension != null,
    module.nullplatform_aro_cluster_base_chart != null,
    helm_release.nullplatform_agent != null,
  ])
}

resource "helm_release" "nullplatform_agent" {
  name             = "nullplatform-agent"
  repository       = "https://nullplatform.github.io/helm-charts"
  chart            = "nullplatform-agent"
  version          = local.nullplatform_base_helm_version  # Configurable version
  namespace        = "nullplatform-tools"
  create_namespace = true

  values = [
    yamlencode({
      configuration = {
        values = {
          NP_API_KEY                  = var.account_level_np_api_key
          TAGS                        = var.tags_selectors
          AGENT_REPO                  = "https://github.com/nullplatform/scopes.git#aroroute"
          AZURE_TENANT_ID             = var.azure_tenant_id
          AZURE_CLIENT_ID             = var.azure_client_id
          AZURE_CLIENT_SECRET         = var.azure_client_secret
          AZURE_SUBSCRIPTION_ID       = var.azure_subscription_id
          RESOURCE_GROUP              = var.azure_resource_group_name
          PUBLIC_GATEWAY_NAME         = "router-internet-facing"
          PRIVATE_GATEWAY_NAME        = "router-internal"
          PRIVATE_HOSTED_ZONE_RG      = var.private_dns_azure_resource_group_name
        }
      }
    })
  ]

  # Wait for base chart and other modules to complete
  depends_on = [
    module.nullplatform_aro_cluster_base_chart,
    module.nullplatform_code_repository,
    module.nullplatform_cloud_provider,
    module.nullplatform_asset_repository,
    module.nullplatform_dimension
  ]
}

########################################################################################
## We're ommiting creation of the agent with the module at this time
########################################################################################
# module "agent" {
#   source         = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/agent?ref=v1.4.0"
#   cluster_name   = var.cluster_name
#   nrn            = var.account_level_nrn
#   # This has to be an organization level API Key with these roles: agent, developer, ops, secops, secrets reader
#   np_api_key = var.np_api_key
#   # Typically this will be a concatenation of your dimension and values (eg: environment:development)
#   tags_selectors = var.tags_selectors
# }

###############################################################################
# K8s Scope Definition | Set this at organization level
###############################################################################
module "scope_definition" {
  source     = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/scope_definition?ref=feature/aro"
  nrn        = var.account_level_nrn
  np_api_key = var.account_level_np_api_key
  depends_on = [helm_release.nullplatform_agent]
}

###############################################################################
# Channel | Typically the cluster NRN level and dimensions
###############################################################################
module "scope_definition_channel" {
  source                     = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/scope_definition_agent_association?ref=v1.4.0"
  nrn                        = var.account_level_nrn
  np_api_key                 = var.account_level_np_api_key
  service_specification_id   = module.scope_definition.service_specification_id
  service_specification_slug = module.scope_definition.service_slug
  tags_selectors             = var.tags_selectors
  enabled_override           = var.enabled_override

  # This is required for ARO since we need an extension on top of vanilla K8s
  overrides_service_path     = var.overrides_service_path
  override_repo_path         = var.override_repo_path

  depends_on = [module.scope_definition]
}

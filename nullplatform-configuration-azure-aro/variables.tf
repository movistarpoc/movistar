############################################
# Azure / Infra Variables
############################################
variable "domain_name" {
  type        = string
  description = "Root domain name (e.g., example.com) used for RG, DNS, and Nullplatform."
}

variable "containerregistry_name" {
  type        = string
  description = "Azure Container Registry name."
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription id."
}

variable "azure_client_id" {}
variable "azure_service_principal_object_id" {
  type        = string
  description = "Azure Service Principal Object ID (not the Client ID)"
}
variable "public_scope_domain_name" {}
variable "private_scope_domain_name" {}

/*
variable "address_space" {
  type = set(string)
  description = "The cidr of your vnet"
}

variable "vnet_name" {
  type = string
  description = "The name of your vnet"
  
}
variable "subnets_definition" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "The subnet definition for the vnet"
  
}
*/
variable "cluster_name" {
  type = string
  default = "test"
  
}
# ############################################
# # Credentials / Nullplatform
# ############################################
# variable "np_api_key" {
#   type        = string
#   description = "Nullplatform API Key."
#   sensitive   = true
# }

# variable "account_level_nrn" {
#   type        = string
#   description = "Target Nullplatform Resource Name (NRN)."
# }

# ############################################
# # Code Repository Config
# ############################################
# variable "group_path" {
#   type        = string
#   description = "Organization/group where repositories will be created (e.g., 'my-org' in GitHub)."
# }

# variable "access_token" {
#   type        = string
#   description = "Git provider access token (GitHub/GitLab) with required permissions."
#   sensitive   = true
# }

# variable "installation_url" {
#   type        = string
#   description = "Installation/App URL for the Git provider (if applicable)."
# }

# variable "collaborators_config" {
#   type        = any
#   description = "Collaborators configuration (list/map as expected by the module)."
# }

# variable "gitlab_repository_prefix" {
#   type        = string
#   description = "Prefix for GitLab repositories (if applicable)."
#   default     = null
# }

# variable "gitlab_slug" {
#   type        = string
#   description = "Group/project slug in GitLab (if applicable)."
#   default     = null
# }

# ############################################
# # Asset Repository (Docker Server)
# ############################################
# variable "login_server" {
#   type        = string
#   description = "Registry login server (e.g., <acr>.azurecr.io)."
# }

# variable "path" {
#   type        = string
#   description = "Path/repo namespace in the registry (e.g., 'apps')."
# }

# variable "username" {
#   type        = string
#   description = "Username to authenticate against the registry (if applicable)."
# }

# variable "password" {
#   type        = string
#   description = "Registry password or token."
#   sensitive   = true
# }

# ############################################
# # Dimensions / Environments
# ############################################
# variable "environments" {
#   type        = any
#   description = "Environment/dimension definition (use the structure expected by the module)."
# }
# variable "nullplatform_accounts" {
#
# }

variable "np_api_key" {
  
}

variable "account_level_np_api_key" {

}

variable "account_level_nrn" {

}

variable "gitlab_access_token" {
  
}

variable "gitlab_group_path" {
  
}

variable "gitlab_installation_url" {
  
}

variable "gitlab_repository_prefix" {
  
}

variable "gitlab_slug" {
  
}

variable "login_server" {
  
}

variable "username" {
  
}

variable "password" {
  
}

variable "path" {
  
}

variable "azure_tenant_id" {
  
}

variable "azure_resource_group_name" {
  
}

variable "private_dns_azure_resource_group_name" {

}

variable "public_dns_azure_resource_group_name" {

}

variable "azure_client_secret" {
  
}



variable "dimensions" {
  
}
variable "environments" {
  
}
variable "gitlab_collaborators_config" {
  
}
variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}
variable "kube_context" {
  type    = string
  default = null 
}

variable "tags_selectors" {

}

variable "enabled_override" {
  
}

variable "overrides_service_path" {
  
}

variable "override_repo_path" {
  
}


variable "exporter_prometheus_port" {
}

variable "application_domain" {
}


###########prometheus###########
 variable "install_prometheus" {
  default = false
   
 }
 variable "prometheus_url" {
  type = string
  default = "http://prometheus-k8s.openshift-monitoring.svc.cluster.local:9091"
   
 }
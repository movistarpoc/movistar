module "prometheus" {
  source               = "git::https://github.com/nullplatform/tofu-modules.git///nullplatform/prometheus?ref=v1.8.0"
  nrn                  = var.nrn
  np_api_key           = var.np_api_key
  prometheus_namespace = var.prometheus_namespace
  prometheus_url       = var.prometheus_url
  install_prometheus   = var.install_prometheus
}
helm repo add nullplatform https://nullplatform.github.io/helm-charts
helm repo update

# Commands to upgrade helm chart base to configure promethus outside the terraform state
helm list -n nullplatform-tools
helm get values nullplatform-agent -n nullplatform-tools

helm upgrade nullplatform-base nullplatform/nullplatform-base --namespace nullplatform-tools --version = 2.26.0 --reuse-values

#Commands to review that pod and permissions for prometheus existis
kubectl get podmonitors.monitoring.coreos.com -A
kubectl get role -A | grep prometheus-k8s
kubectl get RoleBinding  -A | grep prometheus-k8s

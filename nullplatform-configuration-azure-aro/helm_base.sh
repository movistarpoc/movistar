helm repo add nullplatform https://nullplatform.github.io/helm-charts
helm repo update

#######
helm list -n nullplatform-tools
helm get values nullplatform-agent -n nullplatform-tools

helm upgrade nullplatform-base nullplatform/nullplatform-base --namespace nullplatform-tools --version = 2.26.0 --reuse-values

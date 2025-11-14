helm repo add nullplatform https://nullplatform.github.io/helm-charts
helm repo update


#######
helm upgrade --install nullplatform-base nullplatform/nullplatform-base \
  --namespace nullplatform-tools \
  --create-namespace \
  --version = "2.26.0" \
  --set npApiKey="${ACCOUNT_LEVEL_NP_API_KEY}" \
  --set nrn="${ACCOUNT_LEVEL_NRN}" \
  --set cloudProvider="aro" \
  --set ingressControllers.public.name="internet-facing" \
  --set ingressControllers.public.enabled=true \
  --set ingressControllers.public.scope="External" \
  --set ingressControllers.public.domain="poc-movistar.nullapps.io" \
  --set ingressControllers.private.name="internal" \
  --set ingressControllers.private.enabled=true \
  --set ingressControllers.private.scope="Internal" \
  --set ingressControllers.private.domain="poc-movistar-internal.nullapps.io"

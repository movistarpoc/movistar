#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Script: connect-aro.sh
# Description: Connects to an Azure Red Hat OpenShift (ARO) cluster using az and oc.
# Usage:
#   ./connect-aro.sh <RESOURCE_GROUP> <CLUSTER_NAME>
# or set them as environment variables:
#   RESOURCE_GROUP=davidf-test CLUSTER_NAME=test ./connect-aro.sh
# -----------------------------------------------------------------------------

set -euo pipefail

# --- Parse inputs ---
RESOURCE_GROUP=${1:-${RESOURCE_GROUP:-}}
CLUSTER_NAME=${2:-${CLUSTER_NAME:-}}

if [[ -z "$RESOURCE_GROUP" || -z "$CLUSTER_NAME" ]]; then
  echo "❌ Error: RESOURCE_GROUP and CLUSTER_NAME must be provided."
  echo "Usage: $0 <RESOURCE_GROUP> <CLUSTER_NAME>"
  exit 1
fi

echo "🔍 Connecting to ARO cluster..."
echo "   ➤ Resource group: $RESOURCE_GROUP"
echo "   ➤ Cluster name:   $CLUSTER_NAME"
echo

# --- Get credentials ---
echo "🔑 Fetching kubeadmin credentials..."
CREDENTIALS_JSON=$(az aro list-credentials --name "$CLUSTER_NAME" --resource-group "$RESOURCE_GROUP" -o json)
USERNAME=$(echo "$CREDENTIALS_JSON" | jq -r '.kubeadminUsername')
PASSWORD=$(echo "$CREDENTIALS_JSON" | jq -r '.kubeadminPassword')

# --- Get API server URL ---
echo "🌐 Retrieving API server URL..."
API_URL=$(az aro show --name "$CLUSTER_NAME" --resource-group "$RESOURCE_GROUP" --query "apiserverProfile.url" -o tsv)

# --- Connect with oc ---
echo
echo "🚀 Logging in to OpenShift..."
oc login "$API_URL" --username "$USERNAME" --password "$PASSWORD" --insecure-skip-tls-verify=true

# --- Verify connection ---
echo
echo "✅ Login successful! Cluster info:"
oc whoami
oc get nodes -o wide

echo
echo "🎉 Connected to $CLUSTER_NAME successfully!"


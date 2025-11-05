# Pre-requisites

Use this guide once **nullplatform** has set up an organization for you.

- Get API keys from `https://<client-org-slug>.app.nullplatform.io/settings/api-keys/new`
- Get your organization NRN

On Azure:

- **Cluster**
  - Get an **OpenShift cluster**
  - Retrieve the cluster's **client secret**
    - Get the cluster client ID: `kubectl get secret azure-credentials -n kube-system -o jsonpath='{.data.azure_client_id}' | base64 -D && echo ""`
    - Get the client secret through: (Azure) Entra ID > App registrations > (find app by client ID) > Create a secret

- **Networking**
  - You'll need two domains, one public (Pu) and one private (Pr). Note that the Pr zone requires
  also a public zone. This is needed for the certificate issuer to validate the domain ownership.
  - Recommended setup:
    - Public:
      - `<org-slug>.nullapps.io`          (eg: movistar-poc.nullapps.io)
      - `<org-slug>-internal.nullapps.io` (eg: movistar-poc.nullapps.io)
    - Private:
      - `<org-slug>-internal.nullapps.io` (eg: movistar-poc.nullapps.io)

  **Image registry**: Harbor, Azure, Whatever

# 1. Set up the folder for TF

- Require OpenTofu to be downloaded
- Create a new folder with this structure:
    - `backend.tf` (you have to create it)
    - `locals.tf` (provided by nullplatform)
    - `certificate-internal.tf` (provided)
    - `nullplatform-agent-permissions.tf` (provided)
    - `main.tf` (provided)
    - `provider.tf` (provided)
    - `serviceaccountaro.tf` (provided, will be removed in the future)
    - `terraform.tfvars` (fill the provided file)
    - `variables.tf` (provided)

# 2. Apply the terraform

## 2.1. Set up the TF backend

- Go to portal.azure.com and create/get these resources:
    - Azure storage account (eg: `mynullplatformpoc`)
    - Resource group (eg: `rg-for-the-state`)
    - Container name (eg: `movistar`)

- Now you can run `tofu init`

## 2.3: Get the required values for `terraform.tfvars`

- Read inside the file which values you'll require
- Nullplatform must provide some values beforehand (API KEY and NRN)

# 2.4: Run the `manual_commands` folder

These are steps that are not yet terraformed, you'll
need to run them mostly to set up permissions and a few
K8s objects that are specific for ARO

Bear in mind that you'll need credentials over Azure
and the cluster to run them.

There are two scripts to run:
- `run_before_first_deploy.sh`
  - set up private scopes which require terraform which are not modularized yet
  - add permisssions for the agent to create pods and DNS records
- `run_the_agent.sh`
  - applies the agent helmchart the right way to the agent receives ALL the required parameters

# 3. Check your installation
- Check that the cluster ingresses are up, you should see the `router-internal` and `router-internet-facing` services
running as deployments in the `openshift-ingress` namespace.
- Check that the certificates have been set by checking that the `wildcard-tls`and `wildcard-tls-internal` Secret are 
present on the namespace `openshift-ingress`.


# Common issues

** Restart cert manager for it to take config changes**.
```⏺ Bash(kubectl get pods -n cert-manager)
⎿  NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5b8679b77d-5qgqq              1/1     Running   0          118m
cert-manager-cainjector-74884c5758-67hwz   1/1     Running   0          118m
cert-manager-webhook-5c8d5b47b9-mvffx      1/1     Running   0          118m

⏺ Bash(kubectl delete pod -n cert-manager cert-manager-5b8679b77d-5qgqq)
⎿  pod "cert-manager-5b8679b77d-5qgqq" deleted
```


**- The terraform breaks the agent**. The main terraform executes the agent helmchart without all required values,
so bear in mind that after running the terraform, you still need to reapply the chart using the `run_the_agent.sh` script


**- Secrets with certificates are not found on openshift-ingress namespace**. Check if they are on the
`openshift-ingress-operator` namespace and copy them to the `openshift-ingress` namespace.

**- Ingresses do not start.** This usually have to do with TLS ceritficates
not being properly setup. Check if your DNS zones and delegation are correct.
Check for the proper secrets to appear in the `openshift-ingress` namespace

**- Terraform fails to remove scope definitions**
Delete all scopes before deleting the definition.

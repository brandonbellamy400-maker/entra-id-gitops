# 🆔 Entra ID Lifecycle Automation: Terraform + GitHub Actions with OIDC

A home lab where I brought an existing Azure identity-automation resource (an offboarding Logic App) under Terraform control, then connected the repo to Azure with a **GitHub Actions pipeline that signs in using OIDC**, so no passwords or client secrets are stored in GitHub.

**Write it as code → import what already exists → let the pipeline check it → no stored secrets.**

---

## 🏢 Scenario

A fictional company, *BrandonTech*, built its identity automation by clicking around in the Azure portal. That causes three problems:

1. **No history.** Nobody can see who changed what, or roll it back.
2. **Drift.** The live setup slowly stops matching what anyone thinks it is.
3. **Secret risk.** Many CI/CD pipelines log in to Azure with a stored client secret. If that secret leaks, an attacker can log in as the pipeline.

**Goal:** Manage the offboarding automation as Terraform code in GitHub, and let GitHub Actions authenticate to Azure **without any stored secret**.

> Everything was done in my own sandbox tenant and subscription. No real users or production systems were involved.

---

## 🛠️ Skills and Technologies

| Area | What I used |
|---|---|
| Infrastructure as Code | Terraform (`azurerm` and `azuread` providers) |
| Identity automation | Azure Logic App with a **system-assigned managed identity**, triggered by an HTTP request carrying a `userId` |
| CI/CD | GitHub Actions |
| Passwordless auth | Entra ID app registration + **federated identity credential (OIDC)** |
| Tooling | Azure Cloud Shell (PowerShell) |

---

## 📁 Repository Layout

```
.
├── .github/workflows/main.yml   # GitHub Actions pipeline
├── main.tf                      # Resource group, Logic App, HTTP trigger
├── providers.tf                 # Terraform + provider versions, tenant
├── variables.tf                 # Tenant ID, subscription ID, tags
└── .gitignore                   # Keeps state files and local caches out of Git
```

---

## 🚀 Lab Walkthrough

### Phase 1: Writing the Terraform

I worked in Azure Cloud Shell and wrote three files.

**`providers.tf`** pins Terraform and the provider versions and points them at my tenant, so every run uses the same versions.

![providers.tf](Screenshot%202026-05-26%20193103.png)

**`variables.tf`** keeps the tenant ID, subscription ID and naming values in one place instead of hard-coding them everywhere.

![variables.tf](Screenshot%202026-05-26%20193635.png)

**`main.tf`** defines three resources:

| Resource | What it is |
|---|---|
| `azurerm_resource_group.iam_rg` | `rg-iam-automation`, the container for the automation |
| `azurerm_logic_app_workflow.offboard_orchestrator` | `logic-entra-lifecycle-worker`, the offboarding workflow, with a **system-assigned managed identity** so it can call other services without a stored credential |
| `azurerm_logic_app_trigger_custom.http_trigger` | An HTTP POST endpoint that requires a `userId`, so another system can say "offboard this user" |

![main.tf](Screenshot%202026-05-26%20194001.png)

### Phase 2: Initializing and Planning

`terraform init` downloaded the pinned providers. `terraform plan` then showed what Terraform would change before anything was touched.

![terraform init](Screenshot%202026-05-26%20194136.png)
![terraform plan](Screenshot%202026-05-26%20195226.png)

### Phase 3: Importing Existing Resources

The resource group and Logic App **already existed** because I'd originally built them in the portal. Instead of deleting and recreating them, I used `terraform import` to bring them under Terraform's management. This is how real teams move portal-built resources into code without downtime.

![Import resource group](Screenshot%202026-05-26%20195805.png)
![Import Logic App](Screenshot%202026-05-26%20200106.png)

### Phase 4: Applying the Change

`terraform apply` brought Azure in line with the code: it **created** the HTTP trigger and **updated** the Logic App to match the code.

```
Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
```

![terraform apply](Screenshot%202026-05-26%20200259.png)

### Phase 5: Passwordless Login for GitHub Actions (OIDC)

I created an Entra ID **app registration** for the pipeline and added a **federated identity credential** to it:

| Setting | Value | Why it matters |
|---|---|---|
| Issuer | `https://token.actions.githubusercontent.com` | Only trust tokens issued by GitHub Actions |
| Subject | `repo:brandonbellamy400-maker/entra-id-gitops:ref:refs/heads/main` | Only trust **this repo's `main` branch**, not any other repo or branch |

**How it works:** when the workflow runs, GitHub issues a short-lived token that says "I'm this repo, on main." Entra checks it against the federated credential and hands back a short-lived Azure access token. **No password or client secret exists anywhere** to leak or rotate.

![Federated credential](Screenshot%202026-05-26%20201151.png)

I then added three **repository secrets** to GitHub: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` and `AZURE_SUBSCRIPTION_ID`. These are **IDs, not passwords**. They tell the pipeline *which* identity to use, but can't be used to log in on their own.

![GitHub secrets](Screenshot%202026-05-26%20201846.png)

### Phase 6: The Pipeline

The workflow in `.github/workflows/main.yml`:

```yaml
on:
  push:
    branches: [main]

permissions:
  id-token: write   # lets the job request a GitHub OIDC token
  contents: read

env:
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_USE_OIDC: true # tells Terraform to log in with OIDC instead of a secret
```

On every push to `main`, it checks out the code, installs Terraform 1.5.7, signs in to Azure through OIDC, and runs `terraform init` and `terraform plan`.

![Workflow file](Screenshot%202026-05-26%20202420.png)

### Phase 7: Successful Run

The pipeline authenticated to Azure with OIDC and completed successfully, with **no stored secret involved**.

![Successful pipeline run](Screenshot%202026-05-26%20205848.png)

---

## 📊 Results

- The offboarding Logic App and its HTTP trigger are now **defined in code** with full Git history.
- Portal-built resources were **imported** into Terraform instead of being rebuilt.
- GitHub Actions authenticates to Azure using **OIDC federation**, scoped to one repo and one branch, with **zero stored credentials**.

---

## ⚠️ Current Limitations (Honest Notes)

This is a working foundation, not a finished production pipeline:

- **Local state.** There's no remote backend yet, so the pipeline starts with empty state each run. That's why it runs `plan` only. Running `apply` from the pipeline would try to recreate resources that already exist.
- **Push-triggered, not PR-gated.** The workflow runs on pushes to `main`. It doesn't yet run a plan on pull requests for review before merge.
- **No Entra directory objects yet.** The `azuread` provider is configured, but groups and app registrations aren't managed in code yet.
- **The Logic App's steps** (disabling the account, revoking sessions, removing group memberships) aren't defined in this repo yet. Only the workflow shell and trigger are.

---

## ⏭️ Next Steps

- [ ] Add an **Azure Blob Storage remote backend** (`backend "azurerm"` with `use_oidc = true`) so state is shared and locked
- [ ] Run `terraform plan` on **pull requests**, and `terraform apply` only after **merge to `main`**
- [ ] Add **branch protection** so changes to `main` require a reviewed PR
- [ ] Manage **security groups** and **app registrations** with `azuread_group` / `azuread_application`
- [ ] Define the offboarding steps: disable the user, revoke sessions, remove group memberships
- [ ] Narrow the pipeline identity's permissions to only what Terraform needs

---

## 💡 What I Learned

- How Terraform compares **code to reality** and only changes what's different
- How to **import** existing resources instead of rebuilding them
- How **OIDC federation** replaces stored secrets, and how the subject claim restricts which repo and branch can log in
- Why the pipeline's identity must be protected like a **privileged admin account**: whoever can change `main` can change Azure

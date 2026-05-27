# 🆔 Production-Grade Microsoft Entra ID Infrastructure-as-Code & GitOps Pipeline

## 🏢 Business Scenario: The Configuration Drift & Identity Access Shadow Window
* **Company Problem:** Global enterprise logistics provider **BrandonTech** faced audit flags and security risks due to manual configurations within the Microsoft Entra ID tenant. Manual entry introduced configuration drift, lacked version history, and risked human error when provisioning critical enterprise architecture (e.g., security groups, administrative roles, and application registrations). Furthermore, traditional credential-based CI/CD pipelines exposed static client secrets within the repository settings, presenting a major surface vector for credential harvesting.
* **The Solution:** As an Identity and Access Management (IAM) Engineer, I designed and deployed a declarative, zero-trust **GitOps automation pipeline** to completely codify Microsoft Entra ID. Utilizing **Terraform**, the entire directory state is managed strictly as code. To eliminate static credential risks, the automation engine is powered by **GitHub Actions** utilizing passwordless **OpenID Connect (OIDC)** federated identity mapping directly into Azure, enforcing a strict pull-request-driven deployment workflow.

---

## 🛠️ Skills and Technologies Demonstrated
* **Identity-as-Code (IaC):** Advanced Microsoft Entra ID Terraform Provider configuration.
* **DevSecOps & GitOps:** GitHub Actions pipeline engineering, strict branch protections, and peer-review workflows.
* **Zero-Trust Security:** Passwordless OIDC federation, Azure Managed Identities, and least-privilege Graph API scoping.
* **State Management:** Secure remote state configuration with Azure Blob Storage backend locking.

---

## 🚀 Step-by-Step Lab Walkthrough

## Phase 1: Passwordless Federated Authentication (OIDC) Engineering
To completely eliminate the risk of static credential leaks, I established a passwordless OpenID Connect (OIDC) trust between GitHub and Microsoft Entra ID. By creating a dedicated App Registration and configuring a Federated Identity Credential, GitHub Actions securely requests a short-lived JSON Web Token (JWT) directly from the Microsoft identity platform during runtime.

This ensures that the deployment runner assumes a scoped cryptographic identity dynamically, without a single password or secret saved in repository variables.

![OIDC App Registration Setup](Screenshot 2026-05-26 19:26:27.png)

---

## Phase 2: Remote State Architecture & Security Scoping
To maintain a single source of truth across the engineering team, I configured a remote Terraform state backend using a secure Azure Blob Storage container. State locking via Azure Storage ensures zero deployment collisions during parallel team executions. 

Additionally, the federated identity was granted precise Microsoft Graph API directory permissions (`Group.ReadWrite.All`, `Application.ReadWrite.All`, etc.), aligning strictly with the principle of least privilege.

![Terraform Backend and Graph Permissions](Screenshot 2026-05-26 19:31:03.png)

---

## Phase 3: Declarative Directory Codification (Terraform)
In this phase, I translated BrandonTech's identity architecture into declarative Terraform manifests (`.tf`). This configuration explicitly defines enterprise security boundaries, security groups, application objects, and access packages.

The underlying file layout maps out local variables and standard infrastructure targets cleanly:

![Terraform Code Base Layout](Screenshot 2026-05-26 19:36:35.png)

Before sending the changes up to the remote pipeline, I executed a local validation run to verify syntactical integrity and preview the planned directory mutations:

![Terraform Local Validation](Screenshot 2026-05-26 19:40:01.png)

---

## Phase 4: GitOps CI/CD Automation Pipeline (GitHub Actions)
I engineered a multi-stage GitHub Actions workflow designed to enforce strict code-review controls before modifying production identity infrastructure.

The core orchestration file outlines the two distinct target execution conditions:
![GitHub Actions Pipeline Logic](Screenshot 2026-05-26 19:41:36.png)

1. **Pull Request (CI Stage):** Triggered automatically upon a PR submission to `main`. It initializes Terraform, validates format linting, and runs a speculative `terraform plan`. 
2. **Merge to Main (CD Stage):** Triggered only when the PR is approved and merged. The runner authenticates via OIDC, locks the state backend, and executes `terraform apply --auto-approve` to smoothly mutate the active tenant directory environment.

Pushing changes to the repository automatically fires up the workflow triggers:
![Workflow CI Run Trigger](Screenshot 2026-05-26 19:58:05.png)

---

## Phase 5: Live Verification & Pipeline Execution Logs
To validate the reliability of the GitOps model, I submitted a code modification to add new enterprise resources. The pipeline executed sequentially, presenting the precise ledger of infrastructure changes directly inside the automated runner.

The workflow first spins up the initialization and lint validation steps:
![Terraform Init and Validate Stage](Screenshot 2026-05-26 20:01:06.png)

Next, the pipeline renders a structural preview output within the logs for peer review:
![Terraform Plan Execution Output](Screenshot 2026-05-26 20:02:59.png)

Once approved and merged, the deployment runner securely assumes the OIDC identity and applies the state changes directly to the cloud environment:
![Terraform Apply Infrastructure Mutate](Screenshot 2026-05-26 20:11:51.png)

---

## Phase 6: Directory Synchronization & State Drift Validation
Following the pipeline's success, I logged into the Microsoft Entra Admin Center to confirm zero-touch provisioning. The directory objects matched the Git repository configurations precisely.

The newly codified security groups populated immediately within the identity console:
![Entra ID Provisioned Group Verification](Screenshot 2026-05-26 20:18:46.png)

Enterprise applications and permissions mapped cleanly according to our configuration rules:
![Enterprise App Registrations Synchronized](Screenshot 2026-05-26 20:24:20.png)

The finalized directory run updates the live tenant landscape with a clean, fully reconciled state matrix:
![Final State Synchronization Matrix](Screenshot 2026-05-26 20:58:48.png)

---

## 🎯 Engineering Takeaways & Architectural Insights
* **The Power of Declarative Identity:** Shifting identity management from manual GUI clicks to version-controlled files guarantees repeatable, audit-ready environments. Human latency and configuration drift are entirely mitigated.
* **Eliminating Secret Rotation Overhead:** By leveraging GitHub OIDC identity federation, the enterprise drops the operational overhead and risk of rotating long-lived client secrets, significantly strengthening the platform's security posture.
* **Strict Governance Workflows:** Requiring an approved Pull Request before modifying directory permissions protects core infrastructure from unauthorized or unreviewed modifications, aligning beautifully with modern corporate compliance guidelines.

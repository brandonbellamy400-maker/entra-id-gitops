 # 🆔 Production-Grade Microsoft Entra ID Infrastructure-as-Code & GitOps Pipeline

## 🏢 Business Problem: The Configuration Drift & Identity Access Shadow Window
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

<img width="1920" height="1200" alt="OIDC App Registration Setup" src="https://github.com/user-attachments/assets/a67f43f8-2248-406c-aa26-8220ace88b7a" />

---

## Phase 2: Remote State Architecture & Security Scoping
To maintain a single source of truth across the engineering team, I configured a remote Terraform state backend using a secure Azure Blob Storage container. State locking via Azure Storage ensures zero deployment collisions during parallel team executions. 

Additionally, the federated identity was granted precise Microsoft Graph API directory permissions (`Group.ReadWrite.All`, `Application.ReadWrite.All`, etc.), aligning strictly with the principle of least privilege.

<img width="1920" height="1200" alt="Terraform Backend and Graph Permissions" src="https://github.com/user-attachments/assets/e4111e52-28bd-4454-a5f6-e47dd540dd41" />

---

## Phase 3: Declarative Directory Codification (Terraform)
In this phase, I translated BrandonTech's identity architecture into declarative Terraform manifests (`.tf`). This configuration explicitly defines enterprise security boundaries, security groups, application objects, and access packages.

The underlying file layout maps out local variables and standard infrastructure targets cleanly:

<img width="1920" height="1200" alt="Terraform Code Base Layout" src="https://github.com/user-attachments/assets/1e0e4f26-585e-48c6-9d6c-87247fa34723" />

Before sending the changes up to the remote pipeline, I executed a local validation run to verify syntactical integrity and preview the planned directory mutations:

<img width="1920" height="1200" alt="Terraform Local Validation" src="https://github.com/user-attachments/assets/50f551e6-c7e2-45db-b73a-96cd491b8f63" />

---

## Phase 4: GitOps CI/CD Automation Pipeline (GitHub Actions)
I engineered a multi-stage GitHub Actions workflow designed to enforce strict code-review controls before modifying production identity infrastructure.

The core orchestration file outlines the two distinct target execution conditions:

<img width="1920" height="1200" alt="GitHub Actions Pipeline Logic" src="https://github.com/user-attachments/assets/b1e6023e-45b6-4af1-93fd-a8dcbec22ed5" />

1. **Pull Request (CI Stage):** Triggered automatically upon a PR submission to `main`. It initializes Terraform, validates format linting, and runs a speculative `terraform plan`. 
2. **Merge to Main (CD Stage):** Triggered only when the PR is approved and merged. The runner authenticates via OIDC, locks the state backend, and executes `terraform apply --auto-approve` to smoothly mutate the active tenant directory environment.

Pushing changes to the repository automatically fires up the workflow triggers:

<img width="1920" height="1200" alt="Workflow CI Run Trigger" src="https://github.com/user-attachments/assets/57aee701-b9d5-4821-8787-ee90782cd118" />

---

## Phase 5: Live Verification & Pipeline Execution Logs
To validate the reliability of the GitOps model, I submitted a code modification to add new enterprise resources. The pipeline executed sequentially, presenting the precise ledger of infrastructure changes directly inside the automated runner.

The workflow first spins up the initialization and lint validation steps:

<img width="1920" height="1200" alt="Terraform Init and Validate Stage" src="https://github.com/user-attachments/assets/4a43d115-0ea9-4b44-bb12-15e1d7c93820" />

Next, the pipeline renders a structural preview output within the logs for peer review:

<img width="1920" height="1200" alt="Terraform Plan Execution Output" src="https://github.com/user-attachments/assets/89f4b875-48eb-450c-b5b2-d10746feb666" />

Once approved and merged, the deployment runner securely assumes the OIDC identity and applies the state changes directly to the cloud environment:

<img width="1920" height="1200" alt="Terraform Apply Infrastructure Mutate" src="https://github.com/user-attachments/assets/cb92f7db-8b5d-4963-8184-b9af4b290397" />

---

## Phase 6: Directory Synchronization & State Drift Validation
Following the pipeline's success, I logged into the Microsoft Entra Admin Center to confirm zero-touch provisioning. The directory objects matched the Git repository configurations precisely.

The newly codified security groups populated immediately within the identity console:

<img width="1920" height="1200" alt="Entra ID Provisioned Group Verification" src="https://github.com/user-attachments/assets/7ca7bf6a-c6d6-4d84-93fa-6e7fb83455aa" />

Enterprise applications and permissions mapped cleanly according to our configuration rules:

<img width="1920" height="1200" alt="Enterprise App Registrations Synchronized" src="https://github.com/user-attachments/assets/a2eec680-5fdc-4612-8255-d1b46dc6ca3b" />

The finalized directory run updates the live tenant landscape with a clean, fully reconciled state matrix:

<img width="1920" height="1200" alt="Final State Synchronization Matrix" src="https://github.com/user-attachments/assets/ada0a3e9-c306-493c-9da4-ad7fe794450e" />

---

## 🎯 Engineering Takeaways & Architectural Insights
* **The Power of Declarative Identity:** Shifting identity management from manual GUI clicks to version-controlled files guarantees repeatable, audit-ready environments. Human latency and configuration drift are entirely mitigated.
* **Eliminating Secret Rotation Overhead:** By leveraging GitHub OIDC identity federation, the enterprise drops the operational overhead and risk of rotating long-lived client secrets, significantly strengthening the platform's security posture.
* **Strict Governance Workflows:** Requiring an approved Pull Request before modifying directory permissions protects core infrastructure from unauthorized or unreviewed modifications, aligning beautifully with modern corporate compliance guidelines.

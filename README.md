# Multi-Environment AKS Infrastructure with Terraform & Azure DevOps

## Overview

This project implements a **production-style, multi-environment Azure infrastructure platform** using **Terraform**, **Azure DevOps Pipelines**, and **custom Terraform modules**. The goal is to demonstrate real-world Infrastructure-as-Code (IaC) practices including environment isolation, remote state management, role-based access control, secure secret handling, and automated CI/CD-driven provisioning and destruction of cloud resources.

The architecture is intentionally designed to mirror enterprise deployment patterns.

---

## Architecture Summary

The following diagram represents the high-level workflow and system architecture:


<img width="1536" height="1024" alt="ChatGPT Image Jan 23, 2026, 03_17_29 PM" src="https://github.com/user-attachments/assets/f7662904-e1fd-4e17-abbd-1018f39f5cc4" />


**AKS + Terraform + Azure DevOps (Multi-Environment Architecture)**

### Core Flow

1. **Git Repository (Source of Truth)**

   * All Terraform code and modules are stored in Git
   * Any change to infrastructure is performed via Git commits

2. **Azure DevOps Pipelines (CI/CD Engine)**

   * Git push triggers pipeline execution
   * Pipelines handle validation, planning, deployment, and teardown

3. **Terraform (Infrastructure Engine)**

   * Uses remote backend storage
   * Executes environment-specific deployments
   * Calls reusable custom modules

4. **Azure Subscription (Target Environment)**

   * Hosts all deployed resources
   * Enforced through RBAC and Service Principal authentication

---

## Environment Strategy

This project is designed around **environment isolation** using separate Terraform configurations and state files.

### Supported Environments

* **Development (Dev)**
* **Staging (Stage)**

Each environment has:

* Its own Terraform configuration directory
* Its own remote backend state file
* Independent lifecycle management

### Benefits

* Prevents state conflicts
* Allows independent deployments
* Enables safe testing before promotion
* Matches real-world Dev → Stage → Prod patterns

---

## Remote Terraform State Architecture

Terraform state is stored in **Azure Blob Storage** instead of locally.

### Backend Design

* One storage account resource group
* Separate containers per environment
* Independent state files:

```
Dev   -> dev.tfstate
Stage -> stage.tfstate
```

### Why Remote State

* Enables collaboration
* Prevents state corruption
* Allows pipeline execution
* Supports state locking

---

## CI/CD Pipeline Design

Two main pipeline workflows are implemented.

### Infrastructure Creation Pipeline

Triggered when:

* Code is pushed to main branch

Pipeline stages:

1. Terraform Init
2. Terraform Validate
3. Terraform Apply (Dev)
4. Terraform Apply (Stage)

This pipeline:

* Provisions cloud infrastructure
* Applies environment-specific configuration
* Uses service connection authentication

---

### Infrastructure Destruction Pipeline

Used for:

* Resource cleanup
* Cost control
* Environment teardown

This pipeline:

* Executes Terraform Destroy
* Uses the same remote backend
* Ensures clean resource removal

---

## Authentication & Security Model

### Service Principal Authentication

Terraform authenticates to Azure using a dedicated **Service Principal** created via Terraform.

Capabilities:

* Assigned Contributor role for infrastructure management
* Granted additional RBAC permissions when required
* Used by Azure DevOps service connection

---

### Azure Key Vault Integration

Secrets are not stored in code.

Key Vault is used for:

* Secure secret storage
* Pipeline secret access
* Runtime credential handling

RBAC mode is enabled on Key Vault instead of legacy access policies.

---

## Custom Terraform Modules

Instead of monolithic Terraform files, the project uses reusable modules.

### Implemented Modules

#### AKS Module

Handles:

* Kubernetes cluster creation
* Node pool configuration
* Auto-scaling
* Network profile
* SSH access configuration

---

#### Service Principal Module

Handles:

* Service Principal creation
* Role assignments
* Subscription-level access

---

#### Key Vault Module

Handles:

* Vault provisioning
* RBAC configuration
* Secret creation

---

### Benefits of Modular Design

* Cleaner codebase
* Easier debugging
* Reusable across environments
* Enterprise-standard Terraform structure

---

## SSH Access Design

SSH access is handled centrally and injected only where required.

### Implementation

* Public key stored inside repository `.ssh` folder
* Only AKS module reads the SSH key
* Environment layers simply pass the file path

This avoids hardcoding secrets while keeping pipeline compatibility.

---

## Major Challenges Encountered

This project intentionally exposed real infrastructure problems that commonly occur in production environments.

---

### Terraform State Lock Conflicts

Problem:

* Simultaneous local and pipeline Terraform executions
* State file became locked

Resolution:

* Used force unlock when required
* Enforced pipeline-only infrastructure changes

---

### Azure RBAC Permission Failures

Problem:

* Contributor role insufficient for role assignment operations

Resolution:

* Added Owner or User Access Administrator role
* Enabled role assignment permissions

---

### Key Vault Authorization Errors

Problem:

* Service Principal lacked secret read/write permissions

Resolution:

* Assigned Key Vault Secrets Officer role
* Allowed RBAC propagation time

---

### AKS OIDC Configuration Conflict

Problem:

* Azure defaults enabled OIDC issuer
* Terraform attempted to disable it

Resolution:

* Explicitly enabled OIDC issuer in AKS module
* Matched Azure platform defaults

---

### Azure DevOps Hosted Agent Limitation

Problem:

* Microsoft-hosted agents were unavailable or restricted for free-tier pipeline execution
* Required tooling and environment control were not supported reliably

Resolution:

* Deployed a self-hosted Azure DevOps agent on a dedicated VM
* Configured pipelines to use the custom agent pool
* Enabled persistent tooling, stable pipeline execution, and full environment control

---


## Key Lessons Learned

This project reinforced several production-level realities:

* Terraform state management is critical
* Azure RBAC permissions are strict and slow to propagate
* Pipeline agents require resource monitoring
* Infrastructure automation exposes configuration mistakes quickly
* Modular Terraform design drastically improves maintainability

---

## Final Outcome

The final system successfully delivers:

* Fully automated AKS provisioning
* Secure secret handling
* Environment isolation
* CI/CD-driven infrastructure lifecycle
* Production-grade Terraform architecture

This project demonstrates real operational cloud engineering skills rather than simplified demo deployments.

---

## Technologies Used

* Terraform
* Azure DevOps Pipelines
* Azure Kubernetes Service (AKS)
* Azure Storage
* Azure Key Vault
* Microsoft Entra ID (Azure AD)
* Linux Self-hosted Build Agents

---

## Screenshots

![187894C0-4DEB-42F5-BFE4-0310B3A76B28_1_201_a](https://github.com/user-attachments/assets/607c17f2-648d-476a-8113-b1e40faaf61a)


![0FB9C56D-3BBC-4498-99DD-22F48DD8FEBC_1_201_a](https://github.com/user-attachments/assets/ac8ae2a5-473b-43a2-b67e-a84aa31df649)


# CVM misconfiguration scenarios

Terraform configurations and collection of misconfiguration scenarios for AWS, Azure and GCP Confidential VMs. 

## Layout

Each cloud directory contains a single Terraform configuration. Security-related settings (Secure Boot, vTPM, etc.) are driven by variables so that different misconfiguration **scenarios** can be tested by swapping `.tfvars` files.

## Scenarios

Scenarios are `.tfvars` files under `<cloud>/scenarios/` that override default variable values to simulate specific misconfigurations.

For those misconfigurations that are not easily simulated by variable overrides, simply modify the `main.tf` file in the cloud directory to create the desired misconfiguration.

## AWS
| Scenario | Description |
|---|---|
| `noSEVSNP.tfvars` | SEV-SNP not enabled |
| `noSecureBoot.tfvars` | AWS AMI with TPM but without Secure Boot |
| `noTPM.tfvars` | AWS AMI without TPM |

### Azure

| Scenario | Description |
|---|---|
| `nosecureboot.tfvars` | Missing Secure Boot |
| `trustedlaunch.tfvars` | Fully configured Trusted Launch |
| `noOSdiskencryption.tfvars` | Missing OS disk encryption |
| `secureboot.tfvars` | Correct configuration |

### GCP

| Scenario | Description |
|---|---|
| `nosecureboot.tfvars` | Missing Secure Boot |
| `novTPM.tfvars` | Missing vTPM and Secure Boot |
| `sev.tfvars` | Fully configured SEV (instead of SEV-SNP or TDX) |
| `noIntegrityMonitoring.tfvars` | Missing integrity monitoring |

### Running a scenario

```bash
# Plan
terraform -chdir=<cloud> plan -var-file=scenarios/<scenario>.tfvars

# Apply
terraform -chdir=<cloud> apply -var-file=scenarios/<scenario>.tfvars

# Destroy
terraform -chdir=<cloud> destroy -var-file=scenarios/<scenario>.tfvars
```
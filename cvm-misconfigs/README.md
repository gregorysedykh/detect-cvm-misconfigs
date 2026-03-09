# CVM Misconfiguration Scenarios

Terraform configurations and custom Checkov checks for detecting confidential VM misconfigurations across cloud providers.

## Layout

```
cvm-misconfigs/
├── azure/                  # Azure Terraform config + scenarios
│   ├── main.tf
│   ├── variables.tf
│   └── scenarios/
│       ├── nosecureboot.tfvars
│       └── trustedlaunch.tfvars
├── gcp/                    # GCP Terraform config + scenarios
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars    # local infra values (gitignored)
│   └── scenarios/
│       ├── nosecureboot.tfvars
│       ├── novTPM.tfvars
│       └── sev.tfvars
├── aws/                    # AWS
└── custom_checks/          # External Checkov checks per provider
    ├── azure/
    ├── gcp/
    └── aws/
```

Each cloud directory contains a single Terraform configuration. Security-related settings (Secure Boot, vTPM, etc.) are driven by variables so that different misconfiguration **scenarios** can be tested by swapping `.tfvars` files.

## Setup

### Azure

1. Export your subscription ID:

   ```bash
   export TF_VAR_subscription_id="<your-subscription-id>"
   ```

2. Initialise and select a workspace per scenario:

   ```bash
   terraform -chdir=azure init
   terraform -chdir=azure workspace new nosecureboot   # first time only
   terraform -chdir=azure workspace select nosecureboot
   ```

### GCP

1. Authenticate with Application Default Credentials:

   ```bash
   gcloud auth application-default login
   ```

2. Create a local variables file (gitignored) with your project-specific values:

   ```bash
   cp gcp/terraform.tfvars.example gcp/terraform.tfvars
   ```

   Edit `gcp/terraform.tfvars` and set `project_id`, `region`, `zone`, `subnetwork`, and `service_account_email`.

   Alternatively, if you use a service-account key file:

   ```bash
   terraform -chdir=gcp plan -var 'credentials_file=path/to/sa-key.json' ...
   ```

3. Initialise:

   ```bash
   terraform -chdir=gcp init
   ```

## Scenarios

Scenarios are `.tfvars` files under `<cloud>/scenarios/` that override default variable values to simulate specific misconfigurations.

### Azure

| Scenario | Secure Boot | vTPM | Description |
|---|---|---|---|
| `nosecureboot.tfvars` | off | on | Missing Secure Boot |
| `trustedlaunch.tfvars` | on | on | Fully configured Trusted Launch |

### GCP

| Scenario | Secure Boot | vTPM | Integrity Monitoring | CVM Type | Description |
|---|---|---|---|---|---|
| `nosecureboot.tfvars` | off | on | off | SEV_SNP | Missing Secure Boot |
| `novTPM.tfvars` | off | off | off | SEV_SNP | Missing vTPM and Secure Boot |
| `sev.tfvars` | on | on | on | SEV | Fully configured SEV |

### Running a scenario

```bash
# Plan
terraform -chdir=<cloud> plan -var-file=scenarios/<scenario>.tfvars

# Apply
terraform -chdir=<cloud> apply -var-file=scenarios/<scenario>.tfvars

# Destroy
terraform -chdir=<cloud> destroy -var-file=scenarios/<scenario>.tfvars
```

For GCP, the base `terraform.tfvars` is loaded automatically alongside the scenario file:

```bash
terraform -chdir=gcp plan -var-file=scenarios/nosecureboot.tfvars
terraform -chdir=gcp apply -var-file=scenarios/sev.tfvars
```

## Custom Checkov Checks

External checks live in `custom_checks/` and are organised by provider. Current checks:

| Check ID | Provider | What it verifies |
|---|---|---|
| `AzureEnsureSecureBootEnabled` | Azure | `secure_boot_enabled = true` on VMs |
| `GCPEnsureSecureBootEnabled` | GCP | `enable_secure_boot = true` in `shielded_instance_config` |

### Running checks

Point Checkov at a cloud directory and pass the external checks folder:

```bash
# All checks against Azure
checkov -d azure --framework terraform \
  --external-checks-dir custom_checks \
  --var-file azure/scenarios/nosecureboot.tfvars

# Single check against Azure
checkov -d azure --framework terraform \
  --external-checks-dir custom_checks \
  --var-file azure/scenarios/nosecureboot.tfvars \
  -c AzureEnsureSecureBootEnabled

# All checks against GCP
checkov -d gcp --framework terraform \
  --external-checks-dir custom_checks \
  --var-file gcp/scenarios/sev.tfvars

# Single check against GCP
checkov -d gcp --framework terraform \
  --external-checks-dir custom_checks \
  --var-file gcp/scenarios/nosecureboot.tfvars \
  -c GCPEnsureSecureBootEnabled
```
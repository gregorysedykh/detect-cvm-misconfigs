# CVM misconfiguration scenarios

This folder is organised by cloud, then by scenario.

## Layout

- `azure/`: contains Azure CVM misconfiguration scenarios.
- `aws/`: contains AWS CVM misconfiguration scenarios.
- `gcp/`: contains GCP CVM misconfiguration scenarios.

## How to run a scenario

Make sure that you export the `subscription_id` variable for Azure:

```bash
export TF_VAR_subscription_id="<your-subscription-id>"
```

For GCP, authenticate with Application Default Credentials (ADC):

```bash
gcloud auth application-default login
```

Then create a local variables file from the example:

```bash
cp gcp/terraform.tfvars.example gcp/terraform.tfvars
```

Set your own `project_id`, `region`, `zone`, `subnetwork`, and `service_account_email` in `gcp/terraform.tfvars`.
This file is gitignored, so credentials and project-specific values stay local.

For GCP scenarios, use `-var-file` like Azure:

```bash
terraform -chdir=gcp plan -var-file=scenarios/no-confidential.tfvars
terraform -chdir=gcp plan -var-file=scenarios/sev-snp.tfvars
terraform -chdir=gcp plan -var-file=scenarios/sev.tfvars
```

If you prefer a service account key file, pass it with:

```bash
terraform -chdir=gcp plan -var 'credentials_file=<path-to-service-account.json>'
```

1. Authenticate to the target cloud.
2. Initialise the cloud stack.
3. Plan/apply with the scenario file.

Example (Azure, `nosecureboot`):

```bash
terraform -chdir=azure init
terraform -chdir=azure plan -var-file=scenarios/nosecureboot.tfvars
```

Example (GCP):

```bash
terraform -chdir=gcp init
terraform -chdir=gcp plan -var-file=scenarios/no-confidential.tfvars
```

To apply:

```bash
terraform -chdir=azure apply -var-file=scenarios/<scenario>.tfvars
terraform -chdir=azure apply -var-file=scenarios/nosecureboot.tfvars
```

```bash
terraform -chdir=gcp apply -var-file=scenarios/<scenario>.tfvars
terraform -chdir=gcp apply -var-file=scenarios/sev.tfvars
```

To destroy:

```bash
terraform -chdir=azure destroy -var-file=scenarios/<scenario>.tfvars
terraform -chdir=azure destroy -var-file=scenarios/nosecureboot.tfvars
``` 

```bash
terraform -chdir=gcp destroy -var-file=scenarios/<scenario>.tfvars
terraform -chdir=gcp destroy -var-file=scenarios/sev.tfvars
```

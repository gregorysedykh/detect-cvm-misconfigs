# CVM misconfiguration scenarios

This folder is organised by cloud, then by scenario.

## Layout

- `azure/`: contains Azure CVM misconfiguration scenarios.
- `aws/`: contains AWS CVM misconfiguration scenarios.
- `gcp/`: contains GCP CVM misconfiguration scenarios.

## How to run a scenario

1. Authenticate to the target cloud.
2. Initialise the cloud stack.
3. Plan/apply with the scenario file.

Example (Azure, `nosecureboot`):

```bash
terraform -chdir=azure init
terraform -chdir=azure plan -var-file=scenarios/nosecureboot.tfvars
```

To apply:

```bash
terraform -chdir=azure apply -var-file=scenarios/<scenario>.tfvars
terraform -chdir=azure apply -var-file=scenarios/nosecureboot.tfvars
```

To destroy:

```bash
terraform -chdir=azure destroy -var-file=scenarios/<scenario>.tfvars
terraform -chdir=azure destroy -var-file=scenarios/nosecureboot.tfvars
``` 


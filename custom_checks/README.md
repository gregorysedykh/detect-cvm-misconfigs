# Custom Checkov checks

External checks live in `custom_checks/` and are organised by provider.

## How to run a check

Point Checkov at a cloud directory and pass the external checks folder, then use the `-c` flag to specify specific checks to run, or omit it to run all checks in the folder.

_Example for Azure:_

```bash
# All checks against Azure
checkov -d azure --framework terraform \
  --external-checks-dir ../custom_checks \
  --var-file azure/scenarios/nosecureboot.tfvars

# Single check against Azure
checkov -d azure --framework terraform \
  --external-checks-dir ../custom_checks \
  --var-file azure/scenarios/nosecureboot.tfvars \
  -c AzureSecureBootEnabled
```

## AWS
| Check ID | What it verifies |
|---|---|
| `AWSAMINitroTPM` | `lifecycle` block with `precondition` checking that `tpm_support` is available for an `aws_ami` used by a `aws_instance` |
| `AWSAMISecureBoot` | `lifecycle` block with `precondition` checking that `uefi_data` is available and non-null for an `aws_ami` used by a `aws_instance` |
| `AWSCMK` | `kms_key_id` is defined in the `root_block_device` block for an `aws_instance` |
| `AWSSEVSNPEnabled` | `amd_sev_snp = enabled` in `cpu_options` for `aws_instance` | 

## Azure

| Check ID | What it verifies |
|---|---|
| `AzureCMK` | `encryption_type = "ConfidentialVmEncryptedWithCustomerKey"` for a `azurerm_disk_encryption_set` used by a `azurerm_linux_virtual_machine` or `azurerm_windows_virtual_machine` |
| `AzureEnsureCVMSizeAndDE` | Verifies that the chosen size is correct for a CVM and that the disk encryption option is set for a `azurerm_linux_virtual_machine` or `azurerm_windows_virtual_machine` |
| `AzureIntegrityMonitoring` | `GuestAttestation` set up correctly as an `azurerm_virtual_machine_extension` for a `azurerm_linux_virtual_machine` or `azurerm_windows_virtual_machine` |
| `AzureOSDiskEncryptionType` | `security_encryption_type = "DiskWithVMGuestState"` for a `azurerm_linux_virtual_machine` or `azurerm_windows_virtual_machine` |
| `AzureSecureBootEnabled` | `secure_boot_enabled = true` for a `azurerm_linux_virtual_machine` or `azurerm_windows_virtual_machine` |
| `AzureTempDE` | `AzureDiskEncryptionForLinux` set up correctly as an `azurerm_virtual_machine_extension` for a `azurerm_linux_virtual_machine` |

## GCP
| Check ID | What it verifies |
|---|---|
| `GCPCMK` | `kms_key_self_link` is defined in the `disk_encryption_key` block for a `google_compute_disk` |
| `GCPHyperdiskConfidentialMode` | `enable_confidential_compute` is set to `true` for a `google_compute_disk` |
| `GCPIntegrityMonitoringEnabled` | `enable_integrity_monitoring = true` in `shielded_instance_config` for a `google_compute_instance` |
| `GCPSecureBootEnabled` |`enable_secure_boot = true` in `shielded_instance_config` for a `google_compute_instance` |
| `GCPSNPOrTDXEnabled` | Checks that `confidential_instance_config` exists and is set either to `SEV_SNP` or `TDX` for a `google_compute_instance` |
| `GCPVTPMEnabled` | `enable_vtpm = true` in `shielded_instance_config` for a `google_compute_instance` |
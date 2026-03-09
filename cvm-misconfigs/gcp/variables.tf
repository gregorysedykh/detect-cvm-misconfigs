variable "project_id" {
  description = "GCP project ID where resources are managed."
  type        = string
}

variable "region" {
  description = "GCP region for provider-scoped operations."
  type        = string
}

variable "zone" {
  description = "GCP zone where the VM is created."
  type        = string
}

variable "subnetwork" {
  description = "Self-link or name of the subnetwork used by the VM NIC."
  type        = string
}

variable "service_account_email" {
  description = "Service account email attached to the VM."
  type        = string
}

variable "credentials_file" {
  description = "Optional path to a Google credentials JSON file."
  type        = string
  default     = null
}

variable "access_token" {
  description = "Optional OAuth2 access token for Google provider authentication."
  type        = string
  default     = null
}

variable "confidential_instance_type" {
  description = "Confidential instance type (e.g. SEV, SEV_SNP)."
  type        = string
  default     = "SEV_SNP"
}

variable "enable_integrity_monitoring" {
  description = "Enable integrity monitoring on the VM."
  type        = bool
  default     = true
}

variable "enable_secure_boot" {
  description = "Enable Secure Boot on the VM."
  type        = bool
  default     = true
}

variable "enable_vtpm" {
  description = "Enable vTPM on the VM."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to the VM."
  type        = map(string)
  default     = {}
}

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

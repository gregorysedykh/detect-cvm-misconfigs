variable "region" {
  description = "AWS region where resources are deployed."
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type (must support SEV-SNP for CVM use cases)."
  type        = string
  default     = "m6a.large"
}

variable "ami" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "amd_sev_snp" {
  description = "AMD SEV-SNP setting: 'enabled' or 'disabled'."
  type        = string
  default     = "enabled"
}

variable "subnet_id" {
  description = "Subnet ID for the instance network interface."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the security group."
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the instance."
  type        = map(string)
  default     = {}
}
